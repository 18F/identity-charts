
exports.up = function(knex) {
  return knex.schema.createTable('reports', table => {
    table.increments();
    table.string('name');
    table.json('data');
    table.timestamps();
  });
};

exports.down = function(knex) {
  return knex.schema.dropTable('reports');
};
