using SortedVectors, Test

@testset "basics" begin
    sv = SortedVector([2,3,1])
    @test collect(sv) == [1, 2, 3]
    @test length(sv) == 3
    @test size(sv) == (3, )
    @test sv[1] == 1
    @test sv[2] == 2
    @test sv[3] == 3
    @test_throws BoundsError sv[4]
    @test_throws BoundsError sv[0]
    @test_throws BoundsError sv[-1]

    let T = typeof(sv)
        @test eltype(T) ≡ Int
        @test Base.IndexStyle(T) ≡ Base.IndexLinear()
    end

    let sim =  similar(sv)
        @test sim isa Vector{Int}
        @test length(sim) == length(sv)
    end

    @test_throws ArgumentError sv[1] = 7
    @test_throws ArgumentError sv[3] = -1
    @test (sv[1] = 0) == 0
    @test (sv[2] = 1) == 1
    @test (sv[3] = 8) == 8
    @test sv[:] == [0, 1, 8]

    @test parent(sv) ≡ sv.sorted_contents
    @test copy(sv) == sv
    @test sv.order == Base.Order.Forward # field access is API

    @test_throws ArgumentError SortedVector(SortedVectors.CheckSorted(), [3, 1, 2],
                                            Base.Order.Reverse)
    @test SortedVector(SortedVectors.CheckSorted(), [1, 2, 3]) == [1, 2, 3]
end

@testset "search and cut" begin
    sv = SortedVector(1:5)
    xs = [0.5, 1, 1.5, 2, 5, 6]
    @test SortedVectors.cut.(xs, Ref(sv)) == [0, 0, 1, 1, 4, 5]
    @test SortedVectors.cut.(xs, Ref(sv), false) == [0, 1, 1, 2, 5, 5]

    for x in xs
        @test x ∈ xs
        @test x .+ 0.1 ∉ xs
        @test x .- 0.1 ∉ xs
    end

    ys = SortedVector(1:6)
    for i in 0:7
        @test (i ∈ ys) == (1 ≤ i ≤ 6)
    end
end

if VERSION ≥ v"1.10"            # JET fails on old versions
    using JET
    @testset "static analysis with JET.jl" begin
        @test isempty(JET.get_reports(report_package(SortedVectors, target_modules=(SortedVectors,))))
    end
end

@testset "QA with Aqua" begin
    import Aqua
    Aqua.test_all(SortedVectors; ambiguities = false)
    # testing separately, cf https://github.com/JuliaTesting/Aqua.jl/issues/77
    Aqua.test_ambiguities(SortedVectors)
end
