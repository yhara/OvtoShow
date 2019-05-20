# OvtoShow

A presentation tool made with Ovto

## Important files

Client side

- app/assets/javascripts/ovto_app.js.rb
- app/assets/javascripts/channels/presentation.js

Server side

- app/controllers/main_controller.rb
- app/views/main/index.html.erb

## Setup

- `rails db:setup`
- `EDITOR=vi rails credentials:edit`
  
    # Add this
    ovto_show:
      email: 'foo@bar'
      password: 'xxx'
- `cp data/slide.sample.txt data/slide.txt`

## License

MIT
