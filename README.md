### GraphQL cursor pagination in Rails.

So you implemented some graphQL types but it just turns out that returning bazillions of records with
each query introduces some performance issues. "It would be nice to have some pagination" you think to yourself.
In this post we gonna build [graphQL cursor-based](https://graphql.org/learn/pagination/#pagination-and-edges) pagination functionality. The intent of this post is to show as simple and straightforward as possible how to implement graphQL pagination in graphql-ruby. We'll also cover some nasty edge cases, so they won't ambush you in the wild ;)

## Setup

I assume you are using the following ruby and gem versions:
* ruby 2.5
* rails 5.2
* graphql-ruby 1.8.7

First, let's create post model:
```
$ rails g model post title:string content:text published:boolean
$ bundle exec rails db:migrate
```
And seed some sample data to play with:
```java
100.times { |i| Post.create(title: "title #{i}", content: "content #{i}", published: [true, false].sample) }
```

It's time for graphQL post type:

```ruby
# app/graphql/types/post_type.rb

module Types
  class PostType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: true
    field :content, String, null: true
    field :published, Boolean, null: true
  end
end
```

Let's attach it to graphQL schema:
```ruby
# app/graphql/types/query_type.rb

module Types
  class QueryType < Types::BaseObject

    field :posts, [Types::PostType, null: true], null: false
    def posts(**_args)
      Post.all
    end

  end
end
```

For now, query for this resource looks like this:
```
  query {
    posts {
      id
      title
      content
      published
    }
  }
```
and graphQL is politely returning all hundred posts:
```
{
  "data": {
    "posts": [
      {
        "id": "1",
        "title": "title 0",
        "content": "content 0",
        "published": true
      },
      {
        "id": "2",
        "title": "title 1",
        "content": "content 1",
        "published": false
      },
      {
        "id": "3",
        "title": "title 2",
        .
        .
        .
```
But of course it's not quite what we want. So, let's implement basic cursor pagination.

## Pagination

For type with cursor pagination - aka connection, as it has been named by Facebook - we need to define... connection. To do so we are going to add another field to query type:

```ruby
# app/graphql/types/query_type.rb

module Types
  class QueryType < Types::BaseObject

    field :posts, [Types::PostType, null: true], null: false
    def posts(**_args)
      Post.all
    end

    field :posts_connection, Types::PostType.connection_type, null: false
    def posts_connection(**_args)
      Post.all
    end
  end
end
```

As you can see it's pretty straightforward. The interesting part here is invocation of ```connection_type``` which will create connection type for ```Types::PostType```.
Actually, we are done! Now the simplest query for this connection type goes like this:

```
query {
  postsConnection {
    edges {
      node {
        id
        title
        content
        published
      }
    }
  }
}
```
which returns records in following form:
```
{
  "data": {
    "postsConnection": {
      "edges": [
        {
          "node": {
            "id": "1",
            "title": "title 0",
            "content": "content 0",
            "published": true
          }
        },
        {
          "node": {
            "id": "2",
            "title": "title 1",
            "content": "content 1",
            "published": false
          }
        },
        {
          "node": {
            "id": "3",
            "title": "title 2",
            .
            .
            .
```

Query and its result looks more complicated, that's for sure, but where is the actual pagination? For this, graphql-ruby exposes another field in all connection types called ```pageInfo```. There is also an additional ```cursor``` field under ```node``` which will contain a unique id for given node (it's not identical to post record id!). The final query takes following form:

```
query {
  postsConnection(first: 3) {
    pageInfo {
      endCursor
      startCursor
      hasPreviousPage
      hasNextPage
    }
    edges {
      cursor
      node {
        id
        title
        content
        published
      }
    }
  }
}
```

As you probably noticed ```postsConnection``` above takes additional argument: ```first``` which is pretty self explanatory: "query for the first 3 edges (records)". Aforementioned ```pageInfo``` field provides us with, as name suggests, pagination-related info. It's fields are self explanatory I believe. The final result:

```
{
  "data": {
    "postsConnection": {
      "pageInfo": {
        "endCursor": "NA==",
        "startCursor": "Mg==",
        "hasPreviousPage": false,
        "hasNextPage": true
      },
      "edges": [
        {
          "cursor": "Mg==",
          "node": {
            "id": "2",
            "title": "title 1",
            "content": "content 1",
            "published": false
          }
        },
        {
          "cursor": "Mw==",
          "node": {
            "id": "3",
            "title": "title 2",
            "content": "content 2",
            "published": true
          }
        },
        {
          "cursor": "NA==",
          "node": {
            "id": "4",
            "title": "title 3",
            "content": "content 3",
            "published": true
          }
        }
      ]
    }
  }
}
```

to get to the next page we'll provide postsConnection with additional argument:
```
postsConnection(first: 3, after: "NA==") {
  .
  .
  .
```
...which translates to: "query for the first 3 records after node with cursor(node id): ```NA==```"

## Gotcha 1: ```hasPreviousPage``` and ```hasNextPage```

You might presume that ```hasPreviousPage``` and ```hasNextPage``` will provide you with info suggested by its name. GraphQL has a little nasty suprise for you there: ```hasNextPage``` has valid info only when you paginate forward, for example: ```postsConnection(first: 3)```. Analogous ```hasPreviousPage``` when you go backward:  ```postsConnection(last: 3)```. It will become more clear when you'll look at the example below:

Let's query for first 5 cursor ids:
```
query {
  postsConnection(first: 5) {
    edges {
      cursor
    }
  }
}
```

First 5 cursors:

```
{
  "data": {
    "postsConnection": {
      "edges": [
        {
          "cursor": "MQ=="
        },
        {
          "cursor": "Mg=="
        },
        {
          "cursor": "Mw=="
        },
        {
          "cursor": "NA=="
        },
        {
          "cursor": "NQ=="
        }
      ]
    }
  }
}
```

Now let's query for 2 records after second one ```Mg==```:

```
query {
  postsConnection(first: 2, after: "Mg==") {
    pageInfo {
      endCursor
      startCursor
      hasPreviousPage
      hasNextPage
    }
  }
}
```

We get ```pageIfno```:

```
{
  "data": {
    "postsConnection": {
      "pageInfo": {
        "endCursor": "NA==",
        "startCursor": "Mw==",
        "hasPreviousPage": false,
        "hasNextPage": true
      }
    }
  }
}
```

Despite 2 records still being on the previous page, we still get ```"hasPreviousPage": false```. That's right: not ```null``` or ```undefined``` but obviously incorrect ```false```. And it's not a bug. It's this way by design.

Explanation for this is that at Facebook, where GraphQL has its origins, infinite scroll is a way to go for pagination(news feed for example). And for this purpose, information about previous page when you scroll down is just not needed. It would only introduce unnecessary performance overhead. One simple way to mitigate this in the current state of affairs(not very elegant though...) is to make additional query, just to check if there is a previous page. So for the query above it would look like this:

```
query {
  postsConnection(last: 0, before: "Mg==") {
    pageInfo {
      hasPreviousPage
    }
  }
}
```
...which provides us with correct ```hasPreviousPage``` info this time:
```
{
  "data": {
    "postsConnection": {
      "pageInfo": {
        "hasPreviousPage": true
      }
    }
  }
}
```

## Gotcha 2: ```pageCount```

So, you would probably like to know how many pages there is actually. To calculate this, you could do the following: ```total_records_count / records_per_page_count```. So all you really need is info about total records count. It would be nice to query for it like this:

```
query {
  postsConnection() {
    totalCount
    pageInfo {
      hasPreviousPage
    }
    edges {
      node {
        id
      }
    }
  }
}
```
Unfortunately, running this query will result in:
```
{
  "errors": [
    {
      "message": "Field 'totalCount' doesn't exist on type 'PostConnection'",
      .
      .
      .
    }
  ]
}
```
In fact, there is no way to get this info from default connection. The reason is the same as in the case of previous and next page info: total records count is not really needed for infinite scroll pagination and would only introduce performance overhead. The good news is that it can be quite easily implemented though :)

First, we need to define manually our custom connection:
```ruby
# app/graphql/types/posts_connection.rb

class PostsEdgeType < GraphQL::Types::Relay::BaseEdge
  node_type(Types::PostType)
end

class Types::PostsConnection < GraphQL::Types::Relay::BaseConnection
  field :total_count, Integer, null: false
  def total_count
    object.nodes.size
  end
  edge_type(PostsEdgeType)
end
```
So, to define our custom connection we define a class which inherits from a base graphql connection class: ```GraphQL::Types::Relay::BaseConnection```. We also have to define by hand an edge class ```PostsEdgeType``` and then specify that we are going to use it in our connection: ```edge_type(PostsEdgeType)```. Finally way we can add additional fields, like total_count in our example, just the way you would do this in other type classes, like ```Types::PostType```.

Next, we need to specify that we are going to use ```Types::PostsConnection``` as posts_connection type class:
```ruby
module Types
  class QueryType < Types::BaseObject
    ...
    field :posts_connection, Types::PostsConnection, null: false
    ...
  end
end

```

Now, our query with total count works as expected:

```
query {
  postsConnection() {
    totalCount
    pageInfo {
      hasPreviousPage
    }
    edges {
      node {
        id
      }
    }
  }
}
```

```
{
  "data": {
    "postsConnection": {
      "totalCount": 100,
      "pageInfo": {
        "hasPreviousPage": false
      },
      "edges": [
        {
          "node": {
            "id": "1"
          }
        },
        .
        .
        .
```

The drawback of this approach, is of course, that with ```totalCount``` we are introducing N+1 to our connection.
Also, watch out for class name used for our custom connection. It has to end with ```Connection``` (as in our case ```Types::PostsConnection```) to be treated by graphql-ruby as connection. If you need a different naming convention you can state explicitly that a connection type will be used in field definition:

```ruby
  field :posts_connection, Types::PostsConnectionClassName, null: false, connection: true
```

## Conclusion

GraphQL, along with its implementations (like graphql-ruby in our case) is still a very young technology and under rapid development. Thus, there is lack of conventions that would be widely accepted by community, as we are used to in the Rails world. This also applies to graphQL pagination and we should expect changes to its specification and implementation in the future. But until then, this post should prove to be useful on your graphQL path ;)

*Full application code can be found [here](https://github.com/KamilMilewski/graphql_examples_for_blog/tree/cursor_pagination)*
