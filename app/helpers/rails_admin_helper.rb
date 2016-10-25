# :nodoc:
module RailsAdminHelper
  def admin_cart_table(cart)
    res = <<-HTML
      <table class="table">
        #{admin_cart_table_thead(cart)}
        #{admin_cart_table_tbody(cart)}
      </table>
    HTML
    res.html_safe
  end

  def admin_cart_table_thead(_cart)
    <<-HTML
    <thead>
      <tr>
        <th>#{t('activerecord.models.book.one').mb_chars.upcase}</th>
        <th>#{t('views.partials.cart_table.title.qty').mb_chars.upcase}</th>
        <th>#{t('views.partials.cart_table.title.total').mb_chars.upcase}</th>
      </tr>
    </thead>
    HTML
  end

  def admin_cart_table_tbody(cart)
    res = '<tbody>'
    res += cart.map do |item|
      <<-HTML
        <tr>
          <td>
            #{item.book.authors.first.name} -
            #{link_to item.book.title, rails_admin.show_path(model_name: 'book', id: item.book.id)}</td>
          <td>#{item.book_count}</td>
          <td>$ #{item.total_price}</td>
        </tr>
      HTML
    end.join(' ')
    res += '</tbody>'
    res
  end

  def admin_pretty_address(address)
    res = <<-HTML
      <span>
        #{address.first_name} #{address.last_name},
        #{address.address_line},
        #{address.city} #{address.zip},
        #{address.country},
        Phone #{address.phone}
      </span>
    HTML
    res.html_safe
  end

  def admin_pretty_credit_card(card)
    res = <<-HTML
      <span>
        #{card.number},
        #{card.expiration_date.strftime('%m/%Y')}
      </span>
    HTML
    res.html_safe
  end
end
