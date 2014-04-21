Sequel.migration do
  up do
    add_column :users, :provider, String
    add_column :users, :uid, String
  end

  down do
    drop_column :users, :provider
    drop_column :users, :uid
  end
end