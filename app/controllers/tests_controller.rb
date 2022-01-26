class TestsController < Simpler::Controller

  def index
    #render 'tests/list'
    @tests = Test.all
  end

  def create
  end

end
