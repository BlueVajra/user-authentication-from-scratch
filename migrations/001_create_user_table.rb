Sequel.migration do

  up do
    create_table(:users) do
      primary_key :id
      String :user_email
      String :password_digest
    end
  end

  down do
    drop_table(:users)
  end
end