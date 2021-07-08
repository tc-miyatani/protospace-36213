FactoryBot.define do
  factory :user do
    email {Faker::Internet.free_email}
    password = Faker::Internet.password(min_length: 6)
    password {password}
    password_confirmation {password}
    name {Faker::Name.last_name}
    profile {Faker::Lorem.sentence}
    occupation {Faker::Lorem.sentence}
    position {Faker::Lorem.sentence}
  end
end
