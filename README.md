# Shadow Stallion

Scripts for a top-down roguelite action game created in Godot. You can find the build and a playable version on the itch.io [here](https://veygudtek.itch.io/shadowstallion-team1-gold). Or just click the image below.

<div align="center">
  <a href="https://veygudtek.itch.io/shadowstallion-team1-gold">
    <img src="https://img.itch.zone/aW1nLzE2MDcyMzE0LnBuZw==/315x250%23c/0YMJrE.png">
  </a>
</div>


## Features

- Player
  - Move and Dash around
  - Shoot a gun
  - Swing a sword
  - Level up stats using experience gained from defeating enemies
- Enemies
  - 3 types of enemies
  - Pathfinding implemented using Godot's AstarGrid
  - Scaling difficulty based on level
- Random Map Generation
  - Random levels implemented using both depth-first search and breadth-first search
  - Depth-first search is used to determine level shape
  - Breadth-first search is used to determine room distance from start
