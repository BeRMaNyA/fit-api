# fit-api

Lightweight framework for building JSON API's

## Introduction

fit-api is a library based on Rack and inspired by Rails & Sinatra.  
The goal of this gem is to provide simplicity when developing an API with ruby.

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
        * [Halt](#halt)
        * [Params](#params)
        * [Headers](#request-headers)
        * [Callbacks](#callbacks)


## Usage

This is a basic example showing how it works... you can check the demo app from this repository:
[fit-api-demo](http://github.com/bermanya/fit-api-demo)

**api.rb**

```ruby
require 'fit_api'

FitApi::Router.define do
  get '/:name', to: 'app#show'

  root to: 'app#index'
end

class AppController < FitApi::Controller
  def index
    json({ message: 'Hello world' })
  end
  
  def show
    json({ message: "Welcome #{params.name}" })
  end
end

# You can setup any Rack Middleware

FitApi.use Rack::CommonLogger, Logger.new('log/app.log')

Rack::Handler::WEBrick.run FitApi.app
```

```bash
ruby api.rb
```

## Router

It recognizes URLs and invoke the controller's action... the DSL is pretty similar to Rails (obviously not so powerful):

### HTTP methods:

```ruby
get '/test/:name',  to: 'app#test_show'
post '/test',       to: 'app#test_post'
put '/test',        to: 'app#test_put'
delete '/test/:id', to: 'app#test_delete'
```

----

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
  get '/welcome', action: 'hello_world'
end
```

|   Method   |         Path      |  Controller & action  |
|------------|-------------------|-----------------------|
|  **GET**   | /another_action   | app#another_action    |
|  **GET**   | /welcome          | app#hello_world       |

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
not_found to: 'app#error_404'
```

## Controllers

The library provides one class `FitApi::Controller` which should be inherited from your controllers.  
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

You have the method `#json` available, which basically sets the response body.

----

### Request

You can access the Request object like this:

`request`

----

### Halt

You can exit the current action throwing an exception... the default status code is 400

```ruby
halt
halt 500
halt 404, 'Not found'
halt 'Error message'
```

----

### Params

#### GET /users

```bash
curl -i http://localhost:1337/users/:id?name=Berna&age=28&height=180
```

```ruby
params.id         # 1
params.name       # "Berna"
params[:age]      # 28
params['height']  # 180
```

#### POST with params:

```bash
curl -i -X POST  -d 'user[name]=Berna&user[age]=28' http://localhost:1337/users
```

#### POST with JSON:

```bash
curl -i -X POST -H "Content-Type: application/json" -d '{ "user": { "name": "Berna", "age": 28 } }' http://localhost:1337/users
```

Result:

```ruby
params.user.name     # "Berna"
params[:user][:age]  # "28"
```

----

#### #permit

```ruby
params.user.permit(:name, :age)
```

----

#### #except

```ruby
params.user.except(:height)
```

----

### Request Headers

```ruby
request.headers['Authorization']
```

----

### Response Headers

```ruby
headers['Header-Name'] = 'Header Value'
```

----

### Callbacks

```ruby
before_action *actions
after_action *actions, only: %i(index show)
```

## TODO:
- [ ] Implement tests
- [ ] Allow websockets -> `FitApi::Controller#stream`

Any contribution would be appreciated =)
