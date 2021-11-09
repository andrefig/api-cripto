# README
# api-cripto

Simple API for quoting criptocurrency transactions
My first project using Ruby on Rails.
Binance API url is hardcoded
* Ruby version: Rails 6.1.4.1
* SPEC:
Route POST /quote
Request fields:
- action (String): Either “buy” or “sell”
- base_currency (String): The currency to be bought or sold
- quote_currency (String): The currency to quote the price in
- amount (String): The amount of the base currency to be
traded

Response fields 
- price (String): The per-unit cost of the base currency\
- total (String): Total quantity of quote currency
- currency (String): The quote currency

* To do
- Configurable Binance API URL
- Design a nice frontend

