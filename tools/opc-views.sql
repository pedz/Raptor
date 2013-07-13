create view opc_q_a AS
select
 answer.answer_text,
 answer.answer_id,
 answer.answer_type,
 answer.answer_code,
 question.question_text,
 question.question_code,
 question.question_type,
 question.encoding_sequence,
 question.question_id,
 question.retain_save_type
from
  c_answer answer,
  c_opc_information answer_opc,
  c_question question,
  c_opc_information question_opc
where
  answer.answer_id = answer_opc.opc_information_id AND
  question.question_id = question_opc.opc_information_id AND
  answer_opc.parent_id = question_opc.opc_information_id
;
