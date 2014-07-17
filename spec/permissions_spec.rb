require 'rspec'

class MembersController
  def show

  end

  def index
    unless current_user.can_view?(current_account)
      puts "Access denied"
    else
      puts current_account.users()
    end
  end

end

class User
  def can_view?(account)
    account.has_member(self)
  end

  def can_edit?(account)
    account.can_be_edited_by?(self)
  end
end

class Account
  def initialize(owner)
    @members =  {}
    @members[owner] = :owner
  end

  def add_member(member,type)
    @members[member] = type
  end

  def has_member(user)
    @members.has_key?(user)
  end

  def can_be_edited_by?(user)
    @members[user] == :admin || @members[user] == :owner
  end
end

describe "Members" do
  context '#can_view?' do
    it 'returns true when member of an account' do
      owner = User.new
      current_account = Account.new(owner)

      admin = User.new
      current_account.add_member(admin,:admin)

      regular_user = User.new
      current_account.add_member(regular_user,:user)

      expect(owner.can_view?(current_account)).to be_truthy
      expect(admin.can_view?(current_account)).to be_truthy
      expect(regular_user.can_view?(current_account)).to be_truthy
    end

    it 'denies access to user who is not in members' do
      owner = User.new
      current_account = Account.new(owner)

      not_member = User.new

      expect(not_member.can_view?(current_account)).to be_falsey
    end
  end

  context '#can_edit' do
    it 'returns true when admin or owner' do
      owner = User.new
      current_account = Account.new(owner)

      admin = User.new
      current_account.add_member(admin,:admin)

      regular_user = User.new
      current_account.add_member(regular_user,:user)

      expect(owner.can_edit?(current_account)).to be_truthy
      expect(admin.can_edit?(current_account)).to be_truthy
      expect(regular_user.can_edit?(current_account)).to be_falsey
    end
  end
end