require 'test_helper'

class ChunksControllerTest < ActionController::TestCase
  # test "the truth" do
  #   assert true
  # end

  context "upload_chunk" do
    should "return accuess on uploading chunk" do
      put :upload_chunk, :name => "A"
      assert_response 201
    end
  end

  context "destroy_chunks" do
    context "clean delete" do
      setup do
        config = {"stub_delete"=>{"clean"=>true, "failed"=>false, "partially_deleted"=>false}}
        Psych.stubs(:load_file).returns(config)
      end

      should "return success on deleting chunks and manifest" do
        %w(A B C D E).each do |chunk_name|
          delete :destroy_chunk,:name => chunk_name
          assert_response 204
        end
        delete :destroy_chunk,:name => "Manifest.yml", :format => :yml
        assert_response 204
      end
    end

    context "fail delete" do
      setup do
        config = {"stub_delete"=>{"clean"=>false, "failed"=>true, "partially_deleted"=>false}}
        Psych.stubs(:load_file).returns(config)
      end

      should "return error on deleting chunks and manifest" do
        %w(A B C D E).each do |chunk_name|
          delete :destroy_chunk,:name => chunk_name
          assert_response 500
        end
        delete :destroy_chunk,:name => "Manifest.yml", :format => :yml
        assert_response 500
      end
    end

    context "partial delete" do
      setup do
        config = {"stub_delete"=>{"clean"=>false, "failed"=>false, "partially_deleted"=>true}}
        Psych.stubs(:load_file).returns(config)
      end

      should "return success on deleting chunk A" do
        delete :destroy_chunk,:name => "A"
        assert_response 401
      end

      should "return bad_request on deleting chunk B" do
        delete :destroy_chunk,:name => "B"
        assert_response 400
      end

      should "return not_found on deleting chunk C" do
        delete :destroy_chunk,:name => "C"
        assert_response 404
      end

      should "return error on deleting chunk D" do
        delete :destroy_chunk,:name => "D"
        assert_response 500
      end
    end
  end

  context "acquire_credentials" do
    should "return user credentials" do
      get :acquire_credentials, :format => :json, :mosso_id => "id"
      assert_response :success
      credentials = {"user" => {"id" => "ID", "key" => "KEY"}}
      assert_equal credentials, JSON.parse(@response.body)
    end
  end

  context "authenticate" do
    should "return success on authenticating" do
      Kernel.expects(:rand).with(1000).returns(123)
      post :authenticate, :format => :json
      assert_response :success
      expected_service_end_point = "http://test.host/storage_url"
      ord_catalog = {"region" => "ORD", "internalURL" => expected_service_end_point, "publicURL" => expected_service_end_point}
      dfw_catalog = {"region" => "DFW", "internalURL" => expected_service_end_point, "publicURL" => expected_service_end_point}
      lon_catalog = {"region" => "LON", "internalURL" => expected_service_end_point, "publicURL" => expected_service_end_point}
      expected_response = {"auth" => {"token" => {"id" => "123"}, "serviceCatalog" => {"cloudFiles" => [ord_catalog, dfw_catalog, lon_catalog]}}} 
      assert_equal expected_response, JSON.parse(@response.body)
    end
  end

  context "check_for_container" do
    should "return success on querying for container" do
      head :container
      assert_response 204
    end
  end

  context "get_chunk_names" do
    should "return a list of chunk names" do
      get :container, :prefix => "manifest"
      chunk_names = "A\nB\nC\nD\nE"
      assert_equal chunk_names, @response.body
    end
  end
end
