module Admin::VouchersHelper
  def render_voucher_rows vouchers
    safe_join(vouchers.map do |voucher|
      content_tag :tr do
        concat render_voucher_code voucher
        concat render_voucher_name voucher
        concat render_voucher_value voucher
        concat render_voucher_quantity voucher
        concat render_voucher_expired_date voucher
        concat render_voucher_status voucher
      end
    end)
  end

  private

  def render_voucher_code voucher
    content_tag :td, voucher.code
  end

  def render_voucher_name voucher
    content_tag :td, voucher.name
  end

  def render_voucher_value voucher
    content_tag :td, voucher.value
  end

  def render_voucher_quantity voucher
    content_tag :td, voucher.quantity
  end

  def render_voucher_expired_date voucher
    content_tag :td, voucher.expired_date
  end

  def render_voucher_status voucher
    status_class = "voucher-#{voucher.status}"
    content_tag(:td, t("admin.vouchers.statuses.#{voucher.status}"),
                class: status_class)
  end
end
