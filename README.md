# To run server 
  - be rails server
  - be sidekiq -C config/sidekiq.yml
  
# Sidekiq view
  - http://localhost:3000/sidekiq/

# Tests
  - be rails test  

# Use example(without delay)
  - curl -v -H 'Content-Type: application/json' -H 'Accept: application/json' -X POST http://localhost:3000/api/messages -d "{\"message\":{\"body\":\"hello, Dude\", \"delay_to\":\"\", \"sender_id\":\"11\", \"recipient_id\":\"12\", \"locations\":[\"watsapp\", \"telegram\"]}}"