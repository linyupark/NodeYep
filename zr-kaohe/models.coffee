DB = require 'sequelize'
conn = new DB '', '', '', 
	dialect: 'sqlite'
	storage: "#{__dirname}/data.sqlite"

Person = conn.define 'person', 
	name: DB.STRING

Score = conn.define 'score',
	point: DB.INTEGER

Cycle = conn.define 'cycle',
	name: DB.STRING

# 关系
Person.hasMany Score, as: 'score_list'
Cycle.hasMany Person, as: 'person_list'

module.exports = 
	DB: DB
	conn: conn

	Person: Person
	Score: Score
	Cycle: Cycle