# Add new inflection rules using the following format 
# (all these examples are active by default):
Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )

  # I don't much like it but the h_or_s field is singular.  The plural
  # of it is h_or_ses (which should never be used anyway
  inflect.plural /^(.*_)?(h_or_s)$/i, '\1\2es'
  inflect.singular /^(.*_)?(h_or_s)$/i, '\1\2'
  inflect.singular /^(.*_)?(h_or_s)es$/i, '\1\2'

  inflect.plural /^(.*_)?(iris)$/i, '\1\2es'
  inflect.singular /^(.*_)?(iris)$/i, '\1\2'
  inflect.singular /^(.*_)?(iris)es$/i, '\1\2'

  inflect.plural /^(.*_)?(ipar_mes)$/i, '\1\2es'
  inflect.singular /^(.*_)?(ipar_mes)$/i, '\1\2'
  inflect.singular /^(.*_)?(ipar_mes)es$/i, '\1\2'

  inflect.singular /^(.*_)?(cstatus)$/i, '\1\2'
  inflect.singular /^(.*_)?(psar_cia)$/i, '\1\2'
  inflect.singular /^(.*_)?(psar_optional_data)$/i, '\1\2'
  inflect.singular /^(.*_)?(comp_id_or_alias)$/i, '\1\2'
  inflect.singular /^(.*_)?(nls_street_address)$/i, '\1\2'
  inflect.singular /^(.*_)?(exception_process)$/i, '\1\2'
  inflect.singular /^(.*_)?(call_class)$/i, '\1\2'
end
