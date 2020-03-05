function pepato_basic(body_side)
    output = PepatoBasic().init(body_side).upload_data().pipeline().data.output_data;
end