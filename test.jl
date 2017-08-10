workspace()
using Base.Test
include("ActorsWorld.jl");using ActorsWorld

@testset "Actors-World" begin
    @testset "Basic" begin
        or = Orientation(ActorsWorld.DIRECTIONS[1])
        @test orientation_rotate(or,Val{true}).value == ActorsWorld.DIRECTIONS[2]
        @test orientation_rotate(or,Val{false}).value == ActorsWorld.DIRECTIONS[4]
        @test_throws ErrorException Orientation(:foo)
        lo = Location(1,2)
        wo = World(10,13)
        @test location_move(lo,Orientation(ActorsWorld.DIRECTIONS[2])).x == 2
        @test location_fix_ooBound(wo,Location(0,15)) == Location(10,2)
    end
    @testset "World generation" begin
        wo = World(10,12)
        @test wo.size.height == 12
        @test wo.size.width == 10
    end
    @testset "Actors" begin
        kara = Actor_Definition(
            moveable=true,
            turnable=true
        )
        leaf = Actor_Definition(
            passable=true
        )
        wo = World(10,10)
        ac1 = actor_create!(wo,kara,Location(1,3),Orientation(ActorsWorld.DIRECTIONS[1]))
        @test ac1 == wo.actors[1]
        actor_delete!(wo,ac1)
        @test length(wo.actors) == 0
        ac2 = actor_create!(wo,kara,Location(1,3),Orientation(ActorsWorld.DIRECTIONS[1]))
        ac3 = actor_create!(wo,leaf,Location(1,3),Orientation(ActorsWorld.DIRECTIONS[1]))
        @test length(get_actors_at_location(wo,Location(1,3))) == 2
        @test length(get_actors_at_location(wo,Location(2,3))) == 0
        @test_throws ErrorException actor_create!(wo,kara,Location(1,3),
                                                  Orientation(ActorsWorld.DIRECTIONS[1]))
    end
    @testset "World Boundaries" begin
        ka = Actor_Definition(
            moveable=true,
            turnable=true
        )
        wo = World(2,5)
        ac = actor_create!(
            wo,ka,Location(1,1),Orientation(ActorsWorld.DIRECTIONS[1])
        )
        @test_throws ErrorException actor_create!(
            wo,ka,Location(1,10),Orientation(ActorsWorld.DIRECTIONS[1])
        )
        actor_move!(wo,ac,ActorsWorld.DIRECTIONS[1]) # 1,2
        actor_move!(wo,ac,ActorsWorld.DIRECTIONS[1]) # 1,3
        actor_move!(wo,ac,ActorsWorld.DIRECTIONS[1]) # 1,4
        actor_move!(wo,ac,ActorsWorld.DIRECTIONS[1]) # 1,5
        @test ac.location == Location(1,5)
        actor_move!(wo,ac,ActorsWorld.DIRECTIONS[1]) # 1,1
        @test ac.location == Location(1,1)
        actor_move!(wo,ac,ActorsWorld.DIRECTIONS[1]) # 1,2
        @test ac.location == Location(1,2)
        actor_rotate!(ac,true)
        @test ac.orientation == Orientation(ActorsWorld.DIRECTIONS[2])
        actor_move!(wo,ac,ActorsWorld.DIRECTIONS[2]) # 2,2
        actor_move!(wo,ac,ActorsWorld.DIRECTIONS[2]) # 1,2
        @test ac.location == Location(1,2)
    end
    @testset "Moving other Actors" begin
        kara_2 = Actor_Definition(
            moveable=true,
            turnable=true
        )
        mushroom = Actor_Definition(
            moveable=true,
        )
        wo = World(1,5)
        ac_kara_2 = actor_create!(
            wo,kara_2,Location(1,1),Orientation(ActorsWorld.DIRECTIONS[1])
        )
        ac_mushroom = actor_create!(
            wo,mushroom,Location(1,2),Orientation(ActorsWorld.DIRECTIONS[1])
        )
        actor_move!(wo,ac_kara_2,ActorsWorld.DIRECTIONS[1])
        @test ac_mushroom.location.y == 3
        actor_move!(wo,ac_kara_2,ActorsWorld.DIRECTIONS[3])
        ac_mushroom2 = actor_create!(
            wo,mushroom,Location(1,2),Orientation(ActorsWorld.DIRECTIONS[1])
        )
        @test_throws ErrorException actor_move!(wo,ac_kara_2,ActorsWorld.DIRECTIONS[1])
    end
    @testset "Putting and Picking" begin
        wo = World(1,10)
        leaf = Actor_Definition(
            passable=true,
            grabable=true
        )
        kara_p = Actor_Definition()
        kara_ac = actor_create!(wo,kara_p,Location(1,1),Orientation(ActorsWorld.DIRECTIONS[1]))
        actor_putdown!(wo,kara_ac,leaf)
        @test wo.actors[2].actor_definition == leaf
        actor_pickup!(wo,kara_ac)
        @test length(wo.actors) == 1
        @test_throws ErrorException actor_pickup!(wo,kara_ac)
        @test_throws ErrorException actor_putdown!(wo,kara_ac,kara_p)
    end
    @testset "Sensors" begin
        wo = World(10,10)
        acd = Actor_Definition()
        acdp = Actor_Definition(passable=true)
        ac = actor_create!(wo,acd,Location(5,5),Orientation(:NORTH))
        actor_create!(wo,acd,Location(6,5),Orientation(:NORTH))
        actor_create!(wo,acd,Location(5,6),Orientation(:NORTH))
        actor_create!(wo,acdp,Location(5,5),Orientation(:NORTH))
        @test is_actor_definition_left(wo,ac,acd) == false
        @test is_actor_definition_right(wo,ac,acd) == true
        @test is_actor_definition_front(wo,ac,acd) == true
        @test is_actor_definition_right(wo,ac,Actor_Definition(moveable=true)) == false
        @test is_actor_definition_here(wo,ac,acdp) == true
    end
end
