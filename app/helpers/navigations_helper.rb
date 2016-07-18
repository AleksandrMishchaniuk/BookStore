module NavigationsHelper
  def main_menu_proc(css_class = '')
    proc do |primary|
      primary.dom_class = css_class
      primary.item :home, 'Home', root_path
      primary.item :shop, 'Shop', shop_books_path, &category_menu_proc
    end
  end

  def category_menu_proc(css_class_wrap = '', css_class_item = '')
    proc do |category|
      category.dom_class = css_class_wrap
      eval Category.items_for_navigation(css_class_item)
    end
  end

  def user_menu_proc(css_class = '')
    proc do |primary|
      primary.dom_class = css_class
      primary.item :settings, 'Settings', edit_user_settings_path
      primary.item :orders, 'Orders', user_orders_path
      primary.item :admin_panel, 'Admin panel', rails_admin_path, if: -> { can? :access, :rails_admin }
    end
  end

end
