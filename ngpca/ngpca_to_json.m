function json_ngpca = ngpca_to_json(ngpca, fields_to_remove)
    filtered_struct = rmfield(struct(ngpca), fields_to_remove);
    json_ngpca = jsonencode(filtered_struct);
end