# :nodoc:
module NavigationsHelper
  def main_menu_proc(css_class = '')
    proc do |primary|
      primary.dom_class = css_class
      primary.item :home, t('navbar.link.home'), root_locale_path
      primary.item :shop, t('navbar.link.shop'), shop_books_path,
                   &category_menu_proc
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
      primary.item :settings, t('navbar.link.user.settings'),
                   edit_user_settings_path
      primary.item :orders, t('navbar.link.user.orders'),
                   user_orders_path
      primary.item :admin_panel, t('navbar.link.user.admin_panel'),
                   rails_admin_path, if: -> { can? :access, :rails_admin }
    end
  end
end
