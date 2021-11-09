class QuoteSerializer
  include JSONAPI::Serializer
  attributes :price, :total, :currency
end
