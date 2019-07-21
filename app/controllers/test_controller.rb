class TestController < Garlix::Controller
  before_action :set_headers

  def index
    json({ action: @berna })
  end

  def create
    json params.description.user
  end

  def show
    json({ name: params.name })
  end

  def error
    json({ error: 'Page not found' })
  end

  private

  def set_headers
    headers['berna'] = 'test'
  end
end
