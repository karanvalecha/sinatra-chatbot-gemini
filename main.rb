require 'sinatra'
require 'net/http'
require 'json'
require 'redcarpet'
require 'langchain'

get '/' do
  erb :index
end

get '/debug' do
  ENV.to_h.to_json
end

post '/chat' do
  question = params[:question]
  response = fetch_response(question)
  content_type :json
  { text: response_to_html(response), markdown: true }.to_json
end

def ai_conversation(message)
  ai = Langchain::LLM::GoogleGemini.new(api_key: ENV['API_KEY'])
  ai.chat(messages: [{role: "user", parts: [{text: message}]}])
end

def fetch_response(question)
  encoded_question = URI.encode_www_form_component(question)
  ai_conversation(question).chat_completion
rescue StandardError => e
  error = "Error: #{e.message}"
  puts error
  error
end  

def response_to_html(response)
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, fenced_code_blocks: true)
  markdown.render(response)
end
