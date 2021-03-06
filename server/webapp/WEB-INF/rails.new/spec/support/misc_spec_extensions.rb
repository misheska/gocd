module MiscSpecExtensions
  def java_date_utc(year, month, day, hour, minute, second)
    org.joda.time.DateTime.new(year, month, day, hour, minute, second, 0, org.joda.time.DateTimeZone::UTC).toDate()
  end

  def stub_server_health_messages
    assign(:current_server_health_states, com.thoughtworks.go.serverhealth.ServerHealthStates.new)
  end

  def stub_server_health_messages_for_controllers
    assigns[:current_server_health_states] = com.thoughtworks.go.serverhealth.ServerHealthStates.new
  end

  def current_user
    @user ||= com.thoughtworks.go.server.domain.Username.new(CaseInsensitiveString.new("some-user"), "display name")
    @controller.stub(:current_user).and_return(@user)
    @user
  end

  def setup_base_urls
    config_service = Spring.bean("goConfigService")
    if (config_service.currentCruiseConfig().server().getSiteUrl().getUrl().nil?)
      config_service.updateConfig(Class.new do
        def update config
          server = config.server()
          com.thoughtworks.go.util.ReflectionUtil.setField(server, "siteUrl", com.thoughtworks.go.domain.ServerSiteUrlConfig.new("http://test.host"))
          com.thoughtworks.go.util.ReflectionUtil.setField(server, "secureSiteUrl", com.thoughtworks.go.domain.ServerSiteUrlConfig.new("https://ssl.host:443"))
          return config
        end
      end.new)
    end
  end

  def cdata_wraped_regexp_for(value)
    /<!\[CDATA\[#{value}\]\]>/
  end

  def fake_template_presence file_path, content
    controller.prepend_view_path(ActionView::FixtureResolver.new(file_path => content))
  end

  def stub_service_on(obj, service_getter)
    service = double(service_getter.to_s.camelize)
    obj.stub(service_getter).and_return(service)
    service
  end

  def stub_service(service_getter)
    stub_service_on(@controller, service_getter)
  end
end