class ChunksController < ApplicationController
  include ChunksHelper

  before_filter :set_delete_mode, :only => :destroy_chunk

  def destroy_chunk
    respond_to do |format|
      self.send(@delete_mode.to_sym, format)
    end
  end

  def acquire_credentials
    respond_to do |format|
      format.json { render :json => {"user" => {"id" => "ID", "key" => "KEY"}} }
    end
  end

  def authenticate
    service_end_point = "http://#{request.host_with_port}/storage_url"
    ord_catalog = {:region => "ORD", :internalURL => service_end_point, :publicURL => service_end_point}
    dfw_catalog = {:region => "DFW", :internalURL => service_end_point, :publicURL => service_end_point}
    lon_catalog = {:region => "LON", :internalURL => service_end_point, :publicURL => service_end_point}
    respond_to do |format|
      format.json { render :json => {:auth => {:token => {:id => "#{Kernel.rand(1000)}"},:serviceCatalog => {:cloudFiles => [ord_catalog, dfw_catalog, lon_catalog]}}} }
    end
  end

  def container
    respond_to do |format|
      format.html do
        if params[:prefix]
          render :text => chunk_names
        else
          render :nothing => true, :status => 204
        end
      end
    end
  end

  def chunk_names
    chunk_names = "A\nB\nC\nD\nE"
  end

  private
  def set_delete_mode
    config = YAML.load_file("#{Rails.root}/config/delete_chunks_config.yml")
    @delete_mode = config["stub_delete"].invert[true]
  end
end
