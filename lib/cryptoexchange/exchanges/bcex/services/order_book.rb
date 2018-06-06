module Cryptoexchange::Exchanges
  module Bcex
    module Services
      class OrderBook < Cryptoexchange::Services::Market
        class << self
          def supports_individual_ticker_query?
            true
          end
        end

        def fetch(market_pair)
          output = super(ticker_url(market_pair))
          adapt(output, market_pair)
        end

        def ticker_url(market_pair)
          base   = market_pair.base.downcase
          target = market_pair.target.downcase
          "#{Cryptoexchange::Exchanges::Bcex::Market::API_URL}/Api_Order/depth?symbol=#{base}2#{target}"
        end

        def adapt(output, market_pair)
          order_book = Cryptoexchange::Models::OrderBook.new
          depth      = output['data']

          order_book.base      = market_pair.base
          order_book.target    = market_pair.target
          order_book.market    = Bcex::Market::NAME
          order_book.asks      = adapt_orders depth['asks']
          order_book.bids      = adapt_orders depth['bids']
          order_book.timestamp = depth['date']
          order_book.payload   = depth
          order_book
        end

        def adapt_orders(orders)
          orders.collect do |order_entry|
            price, amount = order_entry
            Cryptoexchange::Models::Order.new(price:  price,
                                              amount: amount)
          end
        end
      end
    end
  end
end
