
@testset "PTBLM" begin
    n_targets = 1
    n_features = ()
    Tx = Vector{String}
    Ty = Vector{String}

    for (n_obs, split) in [(42068, :train), (3761, :test)]
        d = PTBLM(split)

        test_supervised_array_dataset(d;
                                      n_obs, n_targets, n_features,
                                      Tx, Ty)
    end
end

@testset "UD_English" begin
    n_features = ()
    Tx = Vector{Vector{String}}
    for (n_obs, split) in [(12544, :train), (2077, :test), (2001, :dev)]
        d = UD_English(split)

        test_unsupervised_array_dataset(d;
                                        n_obs, n_features, Tx)
    end
end

@testset "CMUdict" begin
    n_features = ()
    n_targets = 1
    Tx = String
    Ty = Vector{Symbol}

    d = cmudict()
    n_obs = d.metadata["n_observations"]
    test_supervised_array_dataset(d;
                                  n_obs, n_targets, n_features,
                                  Tx, Ty)

    @test isequal(haskey(d, "A"), true)
    @test isequal(getobs(d, "A"), [:AH0])
    i = findfirst(==("A"), d.features)
    @test isequal(d[i].targets, [:AH0])
end
