User.find_or_create_by!(email: "test@example.com") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
end

User.find_or_create_by!(email: "user@example.com") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
end
