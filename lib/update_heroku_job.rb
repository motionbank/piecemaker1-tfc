class UpdateHerokuJob < Struct.new
  def perform
    Video.update_heroku
  end
end