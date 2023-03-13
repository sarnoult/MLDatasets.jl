export cmudict

function __init__cmudict()
    DEPNAME = "CMUdict"
    SOURCE = "https://svn.code.sf.net/p/cmusphinx/code/trunk/cmudict/cmudict-0.7b"
    SUFFIXES = ["", ".phones", ".symbols"]
    HASHES = ["209a8b4cd265013e96f4658632a9878103b0c5abf62b50d4ef3ae1be226b29e4",
                "ffb588a5e55684723582c7256e1d2f9fadb130011392d9e59237c76e34c2cfd6",
                "408ccaae803641c6d7b626b6299949320c2dbca96b2220fd3fb17887b023b027"]
    register(DataDep(
            DEPNAME,
            """
            Dataset: The CMU Pronouncing Dictionary
            Owner: Carnegie Mellon University 
            Website: http://www.speech.cs.cmu.edu/cgi-bin/cmudict
            Readme: http://svn.code.sf.net/p/cmusphinx/code/trunk/cmudict/00README_FIRST.txt
            
            The files are available for download at the offical
            website linked above. The website mentions different sources for download,
            the one used here is SourceForge. 
            Note that using the data responsibly and respecting copyright remains your
            responsibility. The license is included in the dictionary file, see also the Readme.
            """,
            SOURCE .* SUFFIXES,
            HASHES
        ))
end


"""
    CMUdict(; dir=nothing)

    The [CMU pronouncing dictionary](http://www.speech.cs.cmu.edu/cgi-bin/cmudict) 
    pairs over 130000 American English words to their pronounciation, represented
    as a list of phones. For instance, `WORLD` is transcribed as `W ER1 L D`. 
    The dictionary uses a list of 39 phones extended with stress markers 
    (*0*, *1*, *2* for no stress, primary stress and secondary stress). 
    For instance, `ER1` stands for `ER` with primary stress.

    Fields:

    - phones: phones paired to their type (vowel, fricative, etc.) 
    - symbols: phones extended with stress markers
    - features: words in the dictionary
    - targets: lists of phones for each word.  
    
"""
struct CMUdict <: SupervisedDataset           
    metadata::Dict{String, Any}
    features::Vector{String}
    targets::Vector{Vector{Symbol}}
    phones::Dict{Symbol,String}
    symbols::Vector{Symbol}
end

function cmudict(; dir = nothing)
    FILE = "cmudict-0.7b"
    DEPNAME = "CMUdict"
    dict_path = datafile(DEPNAME, FILE, dir)
    phones_path = datafile(DEPNAME, FILE * ".phones", dir)
    symbols_path = datafile(DEPNAME, FILE * ".symbols", dir)
    
    phones = Dict(Symbol(x[1]) => x[2] for x in map(line -> split(line, "\t"), readlines(phones_path)))
    symbols = Symbol.(readlines(symbols_path))
    features, targets = readentries(dict_path)
    metadata = Dict("n_observations" => length(features), "n_symbols" => length(symbols))
    return CMUdict(metadata, features, targets, phones, symbols)
end

function readentries(dict_path)
    lines = readlines(dict_path)
    comments = findfirst(x -> ! startswith(x, ";;;"), lines) - 1
    entries = map(line -> filter(!isempty, split(line)), Base.Iterators.drop(lines, comments))
    features = collect(first.(entries))
    targets = [Symbol.(x[2:end]) for x in entries]
    return features, targets
end

MLUtils.getobs(d::CMUdict, k::String) = d.targets[findfirst(t -> t == k, d.features)]
Base.haskey(d::CMUdict, k::String) = k ∈ d.features
