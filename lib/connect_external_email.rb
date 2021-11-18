require 'byebug'

class ConnectExternalEmail

  attr_reader :site, :external_email, :local_email, :correspondence_email

  DATABASE = [
    {
      name: "Ms. Client", 
      db_email: "msclient@gmail.com", 
      correspondence_email: "ms.client+shastic@gmail.com", 
      external_emails: {"bank_account_website.biz" => "msclient+bank@gmail.com"},
    },
    {
      name: "Mr. Customer", 
      db_email: "mrcustomer@gmail.com", 
      correspondence_email: "mrcustom.er@gmail.com", 
      external_emails: {}
    },
    {
      name: "Mr. Client", 
      db_email: "mrclient@gmail.com", 
      correspondence_email: "mr.client+shastic@gmail.com", 
      external_emails: {"bank_account_website.biz" => "mrclient+bank@gmail.com"},
    }
  ]

  def initialize(site, external_email)
    @site = site
    @external_email = external_email.downcase
    @local_email = is_gmail? ? control_for_gmail : external_email
    @correspondence_email = find_and_update_user
  end

  def is_gmail?
    domain = @external_email.split("@")[1].split(".")[0]
    domain == "gmail" || domain == "googlemail" ? true : false
  end
  
  def control_for_gmail
    username = @external_email.split("@")[0]
    domain = @external_email.split("@")[1].split(".")
    remove_plus_suffix = username.split("+")[0]
    username = remove_plus_suffix.split(".").join
    email_to_check = username + "@" + domain[0] + "." + domain[1]
  end

  def find_and_update_user
    customer = DATABASE.find { |entry| entry[:db_email] == @local_email}
    return database_new_account_entry unless customer
    customerID = DATABASE.index(customer)
    connection = customer[:external_emails]
    unless connection.has_key?(@site) && connection[@site] == @external_email
      customer[:external_emails][@site] = @external_email
    end
    DATABASE[customerID] = customer
  end
  
  def database_new_account_entry
    "This creates a new account in the database, maybe with a pending tag, using a different branch of imagined code base"
  end

end