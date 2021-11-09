class QuoteController < ApplicationController
	skip_before_action :verify_authenticity_token
	#Desabilitando autenticacao...

	def buy
		#a acao vai ser passada ou diretamente de routes ou da funcao sell...
		params.permit(:action, :base_currency, :quote_currency, :ammount)
		#faz uma primeira cotacao, com poucos itens
 		quote = Quote.new(params,10)
 		#calcula o resultado da cotacao
 		result = quote.calculate
 		#verifica se atendeu, senao faz uma cotacao maior
 		if result[:currency].include?("NA")
 			quote = Quote.new(params,1000)
 			result = quote.calculate
 		end
 		render json: result
		

	end

	def sell
		#o algoritmo eh o mesmo do buy, so muda o param action, que eh passado quando chamamos a funcao.
		self.buy
	end

end

class Quote
	#attr_reader :order_book

	def initialize(params,limit)
		@invert_quote = false
  		invalid = false
		#BTCUSDT é o preço de 1 BTC (base_currency) em USDT (quote_currency), logo o simbolo normal e base_currency+quote_currency:
		@currency = params[:quote_currency]
		@ammount = params[:ammount].to_f
		begin #testa símbolo normal
			symbol = params[:base_currency] + params[:quote_currency]
			response = RestClient.get "https://api.binance.com/api/v3/depth?symbol=#{symbol}&limit=#{limit}"
			json_resp = JSON.parse response 
		rescue
			begin #testa símbolo em ordem contrária
			# E.G.: A binance nao fornece o preco de dolar em BTC, mas somente de BTC em dolar. Neste caso eh necessario calcular a partir da cotacao inversa
				symbol =  params[:quote_currency] + params[:base_currency]
				response = RestClient.get "https://api.binance.com/api/v3/depth?symbol=#{symbol}&limit=#{limit}"
				json_resp = JSON.parse response 
				@invert_quote = true
			rescue #símbolo inválido
				invalid = true
			end
		end
		if invalid==false
			if params[:action] == 'buy'			#Para compra: busca em asks
				json_resp = json_resp["asks"]
			elsif params[:action] == 'sell'		#Para venda: busca em bids
				json_resp = json_resp["bids"]
			else
				 invalid=true
			end
			@order_book = json_resp.map!{ |sr| sr.map(&:to_f) }		#Converte para float
		else
			@currency= "ERROR"
		end


	end

	def calculate
		total=0
		total_base=0
		if @currency == "ERROR"
			price=0
		else
			    @order_book.each do |t_price,t_ammount| #Varre os pares da cotacao (preco da moeda na transacao; qtd disponivel da moeda)
			    	if @invert_quote	#recalcula preco para cotacao reversa
			    		t_ammount = t_ammount*t_price
			    		t_price = 1/t_price
			    	end
			    	remain = @ammount-total_base		#remain = quanto falta comprar de moeda
			    	if (remain)>t_ammount 
			    	#Se a transacao atual nao e suficiente:
			    		total = total + t_ammount*t_price		#Total em quote_currency
			    		total_base = total_base + t_ammount		#Total em base_currency
			    	else
			    	#Se a transacao atual e suficiente:
			    		total = total + remain*t_price	
			    		total_base = total_base + remain
			    		break	    		
			    	end
    			end
    			if total_base<@ammount
    					@currency = @currency +"=>NA"		#Nao ha moeda suficiente disponivel na cotacao
    			end
    			price = total/total_base					#Calcula preco medio na cotacao
		end

		json = {price: price, total: total, currency: @currency}	#Retorna resposta
	end
end