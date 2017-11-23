3.times do |topic|
    Topic.create!(
        title: "Topic #{topic}"
        )
end
puts '3 topics created'

10.times do |blog|
   Blog.create!(
       title: "My blog post number #{blog}",
       body: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum'
       )
end
puts '10 blogs created'

5.times do |skill|
   Skill.create!(
       title: "Rails #{skill}",
       percent_utilized: 15
       )
end
puts '5 skills created'

8.times do |portfolio|
    Portfolio.create!(
        title: "Portoflio title nr #{portfolio}",
        subtitle: 'Ruby on rails',
        body: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
        main_image: 'http://placehold.it/650x400',
        thumb_image: 'http://placehold.it/350x200' 
        )
end
puts '8 portfolios created'

1.times do |portfolio|
    Portfolio.create!(
        title: "Portoflio title nr #{portfolio}",
        subtitle: 'Java',
        body: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
        main_image: 'http://placehold.it/650x400',
        thumb_image: 'http://placehold.it/350x200' 
        )
end
puts '1 portfolios created'

3.times do |technology|
    Portfolio.last.technologies.create!(
        name: "Technology #{technology}"
        )

end
puts '3 technologies created'