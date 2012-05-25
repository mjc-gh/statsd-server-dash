statsd-server-dash
==================

Configurable dashboard for [statsd-server](https://github.com/noahhl/statsd-server). 


### Install

    git clone git://github.com/mikeycgto/statsd-server-dash && cd statsd-server-dash && gem build statsd-server-dash && gem install

### Configuration

Here is a sample rackup file (`config.ru`):

    require 'statsd-server-dash'

    # setup redis and data path
    StatsdServer::Dash.set :redis, 'redis://127.0.0.1:6379'
    StatsdServer::Dash.set :data_path, '/path/to/stats-data'

    # define retention levels (should match stats-server config)
    StatsdServer::Dash.set :retention, "10:2160,60:10080,600:262974"

    run StatsdServer::Dash


