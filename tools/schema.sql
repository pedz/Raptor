CREATE TABLE "c_answer" (
  "update_counter" integer,
  "answer_text" varchar,
  "available_for_dependency" integer,
  "answer_id" integer,
  "answer_type" varchar,
  "answer_code" varchar
);
CREATE TABLE "c_component" (
  "component_id" integer,
  "update_counter" integer,
  "retain_comp_id" varchar,
  "description" varchar,
  "question_set_id" integer,
  "opc_group_id" integer,
  "division_id" integer,
  "use_version" integer
);
CREATE TABLE "c_component_version" (
  "component_version_id" integer,
  "update_counter" integer,
  "component_id" integer,
  "version_number" varchar,
  "description" varchar,
  "ga_date" date,
  "classify" integer
);
CREATE TABLE "c_ignore_base_item" (
  "question_set_id" integer,
  "opc_information_id" integer,
  "update_counter" integer
);
CREATE TABLE "c_opc_dependency" (
  "opc_dependency_id" integer,
  "dependency_opc_information_id" integer,
  "dependent_opc_information_id" integer,
  "update_counter" integer,
  "dependency_type" varchar
);
CREATE TABLE "c_opc_group" (
  "opc_group_id" integer,
  "description" varchar,
  "update_counter" integer,
  "opc_group_name" varchar,
  "division_id" integer,
  "allow_other" integer
);
CREATE TABLE "c_opc_information" (
  "opc_information_id" integer,
  "sequence" integer,
  "description" varchar,
  "type" varchar,
  "parent_id" integer
);
CREATE TABLE "c_overwritten_description" (
  "opc_information_id" integer,
  "update_counter" integer,
  "description" varchar,
  "type" varchar,
  "question_set_id" integer
);
CREATE TABLE "c_question" (
  "update_counter" integer,
  "question_text" varchar,
  "question_code" varchar,
  "retain_field_name" varchar,
  "question_type" varchar,
  "encoding_sequence" integer,
  "question_id" integer,
  "retain_save_type" integer
);
CREATE TABLE "c_question_set" (
  "question_set_id" integer,
  "name" varchar,
  "division_id" integer,
  "type" varchar,
  "update_counter" integer,
  "allow_partial_classification" integer
);
CREATE TABLE "c_question_set_version" (
  "question_set_version_id" integer,
  "update_counter" integer,
  "brand_id" varchar,
  "version" varchar,
  "root_question_id" integer,
  "description" varchar,
  "base_version_id" integer,
  "status" varchar,
  "optional_version_id" integer,
  "question_set_id" integer
);
CREATE TABLE "c_target_component" (
  "target_component_id" integer,
  "update_counter" integer,
  "name" varchar,
  "display_text" varchar,
  "code" varchar,
  "sequence" integer,
  "opc_group_id" integer,
  "parent_id" integer,
  "status" varchar,
  "non_selectable" integer,
  "type" varchar
);
