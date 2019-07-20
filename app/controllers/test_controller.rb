class TestController < Garlix::Controller
  def index
    json({ action: 'index' })
  end

  def show
    json({ name: params.name })
  end
end
