module ChunksHelper
  def partially_deleted format
    case params[:name]
    when "A"
      format.html { head :unauthorized}
    when "B"
      format.html { head :bad_request}
    when "C"
      format.html { head :not_found}
    when "D"
      format.html { head :error}
    else
      format.html { render :nothing => true, :status => 204}
      format.yml { render :nothing => true, :status => 204}
    end
  end

  def clean format
    format.html { render :nothing => true, :status => 204}
    format.yml { render :nothing => true, :status => 204}
  end

  def failed format
    format.html { head :error}
    format.yml { head :error}
  end
end
