#!/usr/bin/env ruby

ambiguous_characters = %w{ O 0 l I 1 |}
special_characters = %w{ ! @ # $ % ^ & * ( ) - _ + = [ ] | ; : " , < . > / ? ~ }

character_set = [('a'..'z'), ('A'..'Z'), (0..9)].map do |item|
  item.to_a
end
character_set.flatten!.map(&:to_s)

ambiguous_characters.each do |ac|
  character_set.delete(ac)
end

5.times do
  password = ""
  64.times do
    password += character_set[rand(character_set.length)].to_s
  end
  puts password
end
