# fit-api

Lightweight framework for building JSON API's

## Introduction

fit-api is a 400 line dependency library based on Rack and inspired by Rails & Sinatra. 
The goal of this library is to provide simplicity when developing an API with ruby.

## Installation

Install the latest version from RubyGems

```
$ gem install fit_api
```

## Table of Contents

* [fit-api](#fit-api)
    * [Table of Contents](#table-of-contents)
    * [Usage](#usage)
    * [Router](#router)
        * [Resource/s](#resources)
        * [Namespace](#namespace)
        * [Controller](#controller)
        * [Root](#root)
        * [404](#customize-error-404-message)
    * [Controllers](#controllers)
        * [Request](#request)
        * [Params](#params)
        * [Headers](#request-headers)
        * [Callbacks](#callbacks)
    * [Rack Middlewares](#rack-middlewares)


## Usage

This is a basic example showing how it works... you can check the demo app from this repository:
[fit-api-demo](/bermanya/fit-api-demo)

**my_app.rb**

```ruby
require 'fit_api'

require_relative 'routes'
require_relative 'app_controller'

Rack::Handler::WEBrick.run FitApi::App.new
```

**routes.rb**

```ruby
FitApi::Router.define do
  get '/:name', to: 'app#show'

  root to: 'app#index'
end
```

**app_controller.rb**

```ruby
class AppController < FitApi::Controller
  def index
    json({ message: 'Hello world' })
  end
  
  def show
    json({ message: "Welcome #{params.name}" })
  end
end
```

```bash
ruby my_app.rb
```

## Router

It recognizes URLs and invoke the controller's action... the DSL is pretty similar to Rails (obviously not to so powerful):

### HTTP methods:

```ruby
get '/test/:name',  to: 'app#test_show'
post '/test',       to: 'app#test_post'
put '/test',        to: 'app#test_put'
delete '/test/:id', to: 'app#test_delete'
```

### Resources

**Nested:**

```ruby
resources :users do
  resource :avatar do
    get :comments
    post :add_comment
  end
end
```

**Endpoints for users:**

|    Method   |        Path        |  Controller & action  |
|-------------|--------------------|-----------------------|
|  **GET**    | /users             | users#index           |
|  **GET**    | /users/:id         | users#show            |
|  **POST**   | /users             | users#create          |
|  **PATCH**  | /users/:id         | users#update          |
|  **DELETE** | /users/:id         | users#destroy         |

**Endpoints for avatar:**

|    Method   |                Path                |  Controller & action  |
|-------------|------------------------------------|-----------------------|
|  **GET**    | /users/:user_id/avatar             | avatar#show           |
|  **POST**   | /users/:user_id/avatar             | avatar#create         |
|  **PATCH**  | /users/:user_id/avatar             | avatar#update         |
|  **DELETE** | /users/:user_id/avatar             | avatar#destroy        |
|  **GET**    | /users/:user_id/avatar/comments    | avatar#comments       |
|  **POST**   | /users/:user_id/avatar/add_comment | avatar#add_comment    |

-----

**Member & Collection:**

```ruby
resources :contacts, only: %i(index) do
  member do
    post :add_activity
  end
  
  collection do
    get :search
  end
end
```

|    Method   |           Path             |  Controller & action  |
|-------------|----------------------------|-----------------------|
|  **GET**    | /contacts                  | contacts#index        |
|  **GET**    | /contacts/search           | contacts#search       |
|  **POST**   | /contacts/:id/add_activity | contacts#add_activity |

-----

### Namespace

Only for paths

```ruby
namespace :test do
  get :hello_world 
  post :hello_world, action: :post_hello_world 
end
```

|   Method   |         Path       |  Controller & action  |
|------------|--------------------|-----------------------|
|  **GET**   | /test/hello_world  | test#hello_world      |
|  **POST**  | /test/hello_world  | test#post_hello_world |

-----

```ruby
namespace '/hello/world', controller: :test do
  get :test
end
```

|  Method  |         Path      |  Controller & action  |
|----------|-------------------|-----------------------|
|  **GET** | /test/world/test  | test#test             |

-----

### Controller

```ruby
controller :app do
  get :another_action
end
```

|   Method   |         Path      |  Controller & action  |
|------------|-------------------|-----------------------|
|  **GET**   | /another_action   | app#another_action    |

-----

### Root

```ruby
root to: 'app#index'
```

|  Method  |  Path  |  Controller & action  |
|----------|--------|-----------------------|
|  **GET** | /      | app#index             |

-----

### Customize error 404 message

```ruby
not_found 'app#error_404'
```

## Controllers

The library provides one father class `FitApi::Controller` that should be inherited from your controllers.  
One limitation is the class name of your controller must end with "Controller", i.e: AppController, UsersController...

```ruby
class AppController < FitApi::Controller
  def index
    json 'hello world'
  end
  
  def process_post
    json params 
  end
end 
```

You have the method `#json` available, basically, it sets the Response body.

### Request

You can access the Request object like this: `request`

### Params

Assuming the following requests:

**GET /users/:id?name=Berna&age=28&height=180**

```ruby
params.id           # 1
params.name         # "Berna"
params[:age]        # 28
params['height']    # 180
```

**POST /test** 

With Params:

```bash
curl -i -X POST  -d 'user[name]=Berna&user[age]=28' http://server:1337/test
```

With JSON:

```bash
curl -i -X POST -H "Content-Type: application/json" -d '{ "user": { "name": "Berna", "age": 28 } }' http://server:1337/test
```

Then we have the following data in our `params` object:

```ruby
params.user             # > Params
params.user.name        # "Berna"
params[:user][:age]     # 28
```

### Request Headers

```ruby
request.headers['Authorization']
```

### Response Headers

```ruby
headers['Header-Key'] = 'Header Value'
```

### Callbacks

```ruby
before_action *actions
after_action *actions, only: %i(index show)
```

## Rack Middlewares

You can set up any rack middleware you want, i.e:

**config.ru**

```ruby
require 'fit_api'

use Rack::CommonLogger, Logger.new('log/app.log')

run FitApi::App.new
```

## TODO:
- [ ] Implement tests
- [ ] Allow websockets -> `FitApi::Controller#stream`

Any contribution would be appreciated =)  
