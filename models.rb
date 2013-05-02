require 'mongoid'

class User
	include Mongoid::Document
	field :name
	field :username
	field :password
	field :phone
	field :qq
	field :email

	has_many :reportItems, :class_name => 'ReportItem', :inverse_of => 'author'
	belongs_to :leadOf, :class_name => 'Team', :inverse_of => 'lead'
	belongs_to :team, class_name: 'Team', :inverse_of => 'members'

	def self.authenticate(username,password)
		u = User.where(:username => username).first
		return nil if u.nil?
		return u if Digest::MD5.hexdigest(password) == u.password
	end

end

class Team
	include Mongoid::Document
	field :name
	
	has_one :lead, :class_name =>'User',:inverse_of => 'leadOf'
	has_many :members, :class_name => 'User', :inverse_of => 'team'
	has_many :reports, :class_name => 'Report', :inverse_of => 'team'
end

class Report
	include Mongoid::Document
	field :audited, :type => Boolean
	field :startDate, :type => Date
	field :endDate, :type => Date
	field :order, :type => Integer
	field :note
	has_many :items, :class_name => 'ReportItem', :inverse_of => 'report'
	belongs_to :team, :class_name => 'Team', :inverse_of => 'reports'

	def self.sort_and_group_by_date(report)
		date_keys,start_date = [], report.startDate
		reps_by_date = {}
		while start_date <=report.endDate do
		  reps_by_date[start_date] = []
		  report.items.each do |item|
		    if item.date.eql? start_date
		      reps_by_date[start_date] << item 
		    end
		  end
		  start_date += 1
		end
		reps_by_date.sort
	end


end

class ReportItem
	include Mongoid::Document
	field :plan
	field :complete
	field :audit
	field :date, :type => Date
	belongs_to :author, :class_name => 'User', :inverse_of => 'reportItems'
	belongs_to :report, :class_name => 'Report', :inverse_of => 'items'
end

class ReportByDate
	def initialize(date)
		@items = []
		@date = date
	end
	def add(item)
		@items << item
	end
end

class ReportByUser
	def initialize(user)
		@items = []
		@user = user
	end
	def add(item)
		@items << item
	end
end

