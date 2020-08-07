require 'net/http'
require 'json'

class AyncRuby

  def initialize
    @count = 0
    @url = 'http://openlibrary.org/search/lists.json?q=book&offset=<OFFSET>&limit=<LIMIT>'
    @per_page = 10
    @total = 500
    puts "\n\n API server will block or throttle with errors if try frequenty. \n\n"
    print "Press y for async else sync= "
    if ['y', 'Y'].include?(gets.chomp)
      @async = true
    end
    
    @urls = (0..(@total/@per_page)).map {
      |i|
      @url.sub('<OFFSET>', (i*@per_page).to_s).sub('<LIMIT>', @per_page.to_s)
    }    
  end
  
  def process
    started_at = Time.now
    if @async
      async_process
    else
      sync_process
    end
    completed_at = Time.now
    puts "\n====== Total time taken #{ (completed_at - started_at) } seconds ======\n"
  end

  private
  def async_process
    threads = []
    @urls.each do |url|
      threads << Thread.new(url){
          uri = URI(url)
          JSON.parse(Net::HTTP.get(uri))['docs'].length
        }
    end
    threads.map(&:join) # like .then in promise. next statement will wait to complete all http requests
    @count = threads.map(&:value).sum
    puts "Total #{@count} records pulled via async(Ruby Multi Threading)."
  end

  def sync_process
    @urls.each do |url|
      uri = URI(url)
      @count += JSON.parse(Net::HTTP.get(uri))['docs'].length
    end

    puts "Total #{@count} records pulled via sync."
  end

end

asyncRuby = AyncRuby.new
asyncRuby.process