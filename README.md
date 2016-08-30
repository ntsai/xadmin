# XAdmin

XAdmin base for [ExAdmin](https://github.com/smpallen99/ex_admin)

[license]: http://opensource.org/licenses/MIT

### Installation

添加 xadmin 到 deps:

#### GitHub with Ecto 2.0

mix.exs
```elixir
  defp deps do
     ...
     {:xadmin, github: "ntsai/xadmin"},
     ...
  end
```


配置 config.exs 文件

config/config.exs
```elixir
  config :xadmin,
  repo: MyProject.Repo,
  module: MyProject,
  modules: [
    MyProject.XAdmin.Dashboard,
  ]

```

下载和编译xadmin库

```
mix do deps.get, deps.compile
```

配置 XAdmin:

```
mix admin.install
```

在 phoenix 路由中添加 xadmin

web/router.ex
```elixir
defmodule MyProject.Router do
  use MyProject.Web, :router
  use XAdmin.Router
  ...
  scope "/", MyProject do
    ...
  end

  # setup the XAdmin routes on /admin
  scope "/admin", XAdmin do
    pipe_through :browser
    admin_routes
  end
```

添加 paging(分页组件配置) 配置到 repo.ex

lib/my_project/repo.ex
```elixir
  defmodule MyProject.Repo do
    use Ecto.Repo, otp_app: :my_project
    use Scrivener, page_size: 10
  end

```

修改 brunch-config.js 文件, 修改 js 和 css 配置，在 admin.install 之后，有增加操作注释在文件中。

启动服务器 `iex -S mix phoenix.server`

浏览 http://localhost:4000/admin  ^O^

## Getting Started

### 添加 Ecto Model 到 XAdmin

使用脚手架 `admin.gen.resource`:

```
mix admin.gen.resource MyModel
```

把添加的模块加入到 config.exs:

config/config.exs

```elixir
config :xadmin,
  repo: MyProject.Repo,
  module: MyProject,
  modules: [
    MyProject.XAdmin.Dashboard,
    MyProject.XAdmin.MyModel, #<-- 这是新添加的模块
  ]
```

查看浏览器 `http://localhost:4000/admin/my_model`

然后你就有 CURD LIST 这些操作了。

### Customizing the index page

使用 `index do` 命令去定义视图.

admin/my_model.ex
```elixir
defmodule MyProject.XAdmin.MyModel do
  use XAdmin.Register
  register_resource MyProject.MyModel do

    index do
      selectable_column

      column :id
      column :name
      actions       # display the default actions column
    end
  end
end
```

### Customizing the form

`form` 宏 的使用例子:

```
defmodule MyProject.XAdmin.Contact do
  use XAdmin.Register

  register_resource MyProject.Contact do
    form contact do
      inputs do
        input contact, :first_name
        input contact, :last_name
        input contact, :email
        input contact, :category, collection: MyProject.Category.all
      end

      inputs "Groups" do
        inputs :groups, as: :check_boxes, collection: MyProject.Group.all
      end
    end
  end
end
```

### Customizing the show page

自定义detail的例子.

```elixir
defmodule MyProject.XAdmin.Question do
  use XAdmin.Register

  register_resource MyProject.Question do
    menu priority: 3

    show question do

      attributes_table   # display the defaults attributes

      # create a panel to list the question's choices
      panel "Choices" do
        table_for(question.choices) do
          column :key
          column :name
        end
      end
    end
  end
end
```

```