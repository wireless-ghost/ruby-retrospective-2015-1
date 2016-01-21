def convert_to_bgn(price, currency)
  if (currency == :usd)
    price = price * 1.7408
  elsif (currency == :eur)
    price = price * 1.9557
  elsif (currency == :gbp)
    price = price * 2.6415
  end
  price.round(2)
end

def compare_prices(first_price, first_currency, second_price, second_currency)
  first_converted_price = convert_to_bgn(first_price, first_currency)
  second_converted_price = convert_to_bgn(second_price, second_currency)

  first_converted_price <=> second_converted_price
end
