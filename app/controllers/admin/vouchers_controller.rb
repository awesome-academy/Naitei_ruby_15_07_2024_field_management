class Admin::VouchersController < Admin::BaseController
  def index
    @q = Voucher.ransack(params[:q])
    @vouchers = @q.result(distinct: true)
    @pagy, @vouchers = pagy @vouchers,
                            limit: Settings.vouchers.pagy_10
  end

  def new
    @voucher = Voucher.new
  end

  def create
    @voucher = Voucher.new voucher_params
    if @voucher.save
      flash[:success] = t "admin.vouchers.messages.created_successfully"
      redirect_to admin_vouchers_path
    else
      flash.now[:danger] = t "admin.vouchers.messages.creation_failed"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def voucher_params
    params.require(:voucher).permit Voucher::PERMITTED_ATTRIBUTES
  end
end
