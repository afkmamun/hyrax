require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'mocha'


# See cucumber tests (ie. /features/edit_document.feature) for more tests, including ones that test the edit method & view
# You can run the cucumber tests with 
#
# cucumber --tags @edit
# or
# rake cucumber

describe CatalogController do
  
  before do
    #controller.stubs(:protect_from_forgery).returns("meh")
    session[:user]='bob'
  end
  
  it "should use CatalogController" do
    controller.should be_an_instance_of(CatalogController)
  end
  
  
  describe "Paths Generated by Custom Routes:" do
    # paths generated by custom routes
    it "should map {:controller=>'catalog', :action=>'index'} to GET /catalog" do
      { :get => "/catalog" }.should route_to(:controller => 'catalog', :action => 'index')
    end
    it "should map {:controller=>'catalog', :action=>'show', :id=>'test:3'} to GET /catalog/test:3" do
      { :get => "/catalog/test:3" }.should route_to(:controller => 'catalog', :action => 'show', :id=>'test:3')
    end
    it "should map {:controller=>'catalog', :action=>'show', :id=>'test:3'} to GET /catalog/test:3" do
      { :get => "/catalog/test:3/edit" }.should route_to(:controller => 'catalog', :action => 'edit', :id=>'test:3')
    end
    it "should map {:controller=>'catalog', :action=>'delete', :id=>'test:3'} to DELETE /catalog/test:3" do
      { :delete => "/catalog//test:3" }.should route_to(:controller => 'catalog', :action => 'destroy', :id=>'test:3')
    end

    it "should map catalog_path" do
      # catalog_path.should == '/catalog'
      catalog_path("test:3").should == '/catalog/test:3'
    end
  end
  
  it "should not choke on objects with periods in ids (ie Fedora system objects)" do    
    pending "this would require a patch to all routes that allows periods in ids. for now, use rake solrizer:fedora:forget_system_objects"
    catalog_path("fedora-system:FedoraObject-3.0").should == '/catalog/fedora-system:FedoraObject-3.0'
    route_for(:controller=>"catalog", :action=>"show", :id=>"fedora-system:FedoraObject-3.0").should == '/catalog/fedora-system:FedoraObject-3.0'
  end
  
  describe "index" do
    
    describe "access controls" do
      before(:all) do
        @public_only_results = Blacklight.solr.find Hash[:phrases=>{:access_t=>"public"}]
        @private_only_results = Blacklight.solr.find Hash[:phrases=>{:access_t=>"private"}]
      end

      it "should only return public documents if role does not have permissions" do
        pending("FIXME")
        request.env["WEBAUTH_USER"]="Mr. Notallowed"
        get :index
        assigns("response").docs.count.should == @public_only_results.docs.count
      end
      it "should return all documents if role does have permissions" do
        pending("adjusted for superuser, but assertions aren't working as with test above")
        mock_user = mock("User", :login=>"BigWig")
        session[:superuser_mode] = true
        controller.stubs(:current_user).returns(mock_user)
        get :index
        # assigns["response"].docs.should include(@public_only_results.first)
        # assigns["response"].docs.should include(@private_only_results.first)
        assigns["response"].docs.count.should > @public_only_results.docs.count
      end
    end
  end
  
  describe "filters" do
    describe "index" do
      it "should trigger enforce_index_permissions" do
        controller.expects(:enforce_index_permissions)
        get :index
      end
    end
    describe "show" do
      it "should trigger enforce_show_permissions" do
        controller.expects(:enforce_show_permissions)
        get :index
      end
    end
    describe "edit" do
      it "should trigger enforce_edit_permissions" do
        controller.expects(:enforce_edit_permissions)
        get :index
      end
    end
  end
  
end