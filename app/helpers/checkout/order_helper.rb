module Checkout::OrderHelper
  def preaty_address(address)
    haml_tag :span, "#{address.first_name} #{address.last_name}"
    haml_tag :br
    haml_tag :span, "#{address.address_line}"
    haml_tag :br
    haml_tag :span, "#{address.city} #{address.zip}"
    haml_tag :br
    haml_tag :span, "#{address.country}"
    haml_tag :br
    haml_tag :span, "Phone #{address.phone}"
  end

  def preaty_credit_card(card)
    haml_tag :span, "**** **** **** #{card.number[-4,4]}"
    haml_tag :br
    haml_tag :span, card.expiration_date.strftime("%m/%Y")
  end
end
