require 'connect_external_email'
require 'byebug'
describe "Class::ConnectExternalEmail" do
  subject(:person_1) { ConnectExternalEmail.new("http://web.site", "per.son_1+outside@gmail.com") } 
  subject(:person_2) { ConnectExternalEmail.new("http://web.site", "per.son_2+outside@yahoo.com") } 
  subject(:ms_client_1) { ConnectExternalEmail.new("https://bank.com", "ms.client+bank@gmail.com") } 
  subject(:ms_client_2) { ConnectExternalEmail.new("bank_account_website.biz", "ms.client+bank@gmail.com") } 
  subject(:mr_client) { ConnectExternalEmail.new("bank_account_website.biz", "mrclient+bank@gmail.com") } 
  
  let(:dbconstant) {
    dbconstant = [
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
      },
    ]
  }

  describe "#initialize" do
      it 'sets @external_email to email argument' do
        expect(person_1.external_email).to eq("per.son_1+outside@gmail.com")
      end
      it 'sets @site to URL argument' do
        expect(person_1.site).to eq("http://web.site")
      end
      it 'sets @local_email to gmail-controlled email address' do
        expect(person_1.local_email).to eq("person_1@gmail.com")
      end
  end

  describe "#is_gmail?" do
    it 'returns a boolean based on google domain name' do
      expect(person_1.is_gmail?).to be(true)
      expect(person_2.is_gmail?).to be(false)
    end
  end

  describe "#control_for_gmail" do
    it "should only be called for gmail and googlemail domains" do
      expect(person_2.local_email).to eq("per.son_2+outside@yahoo.com")
    end
    it "should otherwise remove anything after a '+' sign and all dots before the '@' and return email string" do
      expect(person_1.control_for_gmail).to eq("person_1@gmail.com")
    end
  end

  describe "#find_and_update_user" do
    it "if not found, should return end-of-demo string" do
      expect(person_1.find_and_update_user).to eq(person_1.database_new_account_entry)
    end
    context "if found, check for existing entry" do
      it "should not update if identical entry" do
        expect(mr_client.find_and_update_user).to include(
          name: "Mr. Client", 
          db_email: "mrclient@gmail.com", 
          correspondence_email: "mr.client+shastic@gmail.com", 
          external_emails: {"bank_account_website.biz" => "mrclient+bank@gmail.com"},
        )
      end
      it "should add entry if unique new entry" do
        expect(ms_client_1.find_and_update_user).to include(
            name: "Ms. Client", 
            db_email: "msclient@gmail.com", 
            correspondence_email: "ms.client+shastic@gmail.com", 
            external_emails: {
              "bank_account_website.biz"  => "msclient+bank@gmail.com",
              "https://bank.com" => "ms.client+bank@gmail.com"
            },
          )
        end
        it "should update entry if altered gmail syntax" do
        expect(ms_client_2.find_and_update_user).to include(
            name: "Ms. Client", 
            db_email: "msclient@gmail.com", 
            correspondence_email: "ms.client+shastic@gmail.com", 
            external_emails: {
              "bank_account_website.biz"  => "ms.client+bank@gmail.com",
              "https://bank.com" => "ms.client+bank@gmail.com"
            },
          )
      end
    end
  end
end