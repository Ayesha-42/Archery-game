# Encoding: UTF-8
# This is the Custom Program designed and coded by Ayesha Shaikh, 103165863
# as part of her unit's portfolio and requirements to aim for a Distinction level in COS10009 Introduction to Programming

# References- Foodhunter and Captain ruby game programs perscribed by the unit in its material


# Aim of the game
#  * Shoot arrows aimed best at the target to score maximum with a bullseye
#  * Adjust bow's angle and width to get desired speed and direction to aim correctly
#  * Difficulty increases as the level number increases with obstacles blocking and distracting the path of the arrow
#  * The player has only 10 chances or arrows to acheive maximum score in the game

# Basic overview of code
#  1. uses structured programming principles 
#  2. written following the gosu syntax and procedural format
#  3. Modularity and functional decompostion is evident
#  4. guidelines of the task description, presentation and programming practices have kept in mind


require 'rubygems'
require 'gosu'

#game window dimensions
WIDTH=1000
HEIGHT=700

#z-axes layers
module ZOrder
    BACKGROUND, MIDDLE, TOP = *0..2
end

#record of Bow attributes and procedures
class Bow
    attr_accessor :release, :bow_image, :cur_image, :angle, :x, :y

    def initialize()
      
        @release=false
        @angle=0.0
        @x=100
        @y=HEIGHT/2
        @bow_image=Array.new()

    end

    def expand(bow ,arrow)
        #change tile of bow image
        #change xcoordinate of arrow=> minus, to keep it inline with the bow tile-image
        #change vel_x of arrow=>faster
        if(bow.cur_image==bow_image[1])
            bow.cur_image=bow_image[2]
            arrow.vel_x=8
            return
        end

        if(bow.cur_image==bow_image[0])
            bow.cur_image=bow_image[1]
            arrow.vel_x=5
            return
        end
       
    end

    def compress(bow, arrow)
        #change tile of bow image
        #change x coordinate of arrow=> plus
        #change vel_x of arrow=> slower
        if(bow.cur_image==bow_image[2])
            bow.cur_image=bow_image[1]
            arrow.vel_x=5
            return
        end
     
        if(bow.cur_image==bow_image[1])
            bow.cur_image=bow_image[0]
            arrow.vel_x=2
            return
        end

    end

    def tilt_up(bow, arrow)
        #change angle of bow and arrow=>upward
        #change vel_y of arrow=> minus
        bow.angle-=10.0
        arrow.vel_y-=0.5

    end

    
    def tilt_down(bow, arrow)
        #change angle of bow and arrow=>downward
        #change vel_y of arrow => plus
        bow.angle+=10.0
        arrow.vel_y+=0.5

    end

end


#record for the arrow attributes and procedures
class Arrow
    attr_accessor :release, :arrow_image, :vel_x, :vel_y, :angle, :x, :y, :count, :end

    def initialize()
        @vel_x=2
        @vel_y=0
        @x=180
        @y=320
        @count=11
        @angle=0.0
        @release=false
        @end=true
        @arrow_image= Gosu::Image.new("media/arrow.png")

    end
#release of the arrow from the bow towards the target
    def shoot arrow
        arrow.x+=arrow.vel_x
        arrow.y+=arrow.vel_y
    end

end


#record for the target attributes and procedures
class Target
    attr_accessor :x, :y, :vel_y, :angle, :score, :yay, :ohno, :target_image, :result

    def initialize()
        @x=800
        @y=HEIGHT/2
        @score=0
        @yay = Gosu::Sample.new("media/yay.mp3")
        @ohno = Gosu::Sample.new("media/ohno.mp3")
        @target_image= Gosu::Image.new("media/target.png")
        @angle=0.0
        @vel_y=2
        @result=Array.new(3)
            @result=["Better Luck next time", "Good Job" , "Excellent!"]
     
    end

   #to check if the arrow hits the target and where and give points if so
    def collide(target, arrow, flag)
 
        if arrow.x>840 and arrow.x<920
    
            if arrow.y>(target.y+20) and arrow.y<(target.y+40) || arrow.y>(target.y+120) and arrow.y<(target.y+140) #arrow hits the outter rim/band
                target.score+=1
                arrow.count-=1
                target.yay.play
                sleep(2)
                arrow.x=180
                arrow.y=320
                arrow.end=true
                flag=0

            elsif arrow.y>(target.y+40) and arrow.y<(target.y+60) || arrow.y>(target.y+100) and arrow.y<(target.y+120) #arrow hits the middle rim/band
                target.score+=2
                arrow.count-=1
                target.yay.play
          
                sleep(2)
                arrow.x=180
                arrow.y=320
                arrow.end=true
                flag=0
   
            elsif arrow.y>(target.y+60) and arrow.y<(target.y+100)  #arrow hits the bullseye or innermost band
                target.score+=3
                arrow.count-=1
                target.yay.play
                sleep(2)
                arrow.x=180
                arrow.y=320
                arrow.end=true
                flag=0
    
            end

        end

        if arrow.x>WIDTH+40 || arrow.y<0 || arrow.y>HEIGHT                                #misses target
              arrow.count-=1
              target.ohno.play
              sleep(2)
              arrow.x=180
              arrow.y=320
              arrow.end=true
                flag=0
           
        end

        return flag
        end
      
    
    def move target         #verticle movement of the target
        if target.y==500 || target.y==20
            target.vel_y*=-1
        end

        target.y+=vel_y
        
    end

end


#record for the obstacle properties and behaviour
class Obstacle
    attr_accessor :x, :y, :vel_y, :angle, :image, :type

    def initialize(image, type)
        @x=rand(300..700)
        @y=rand(200..600)
        @vel_y=0.5
        @angle=0.0
        @image = Gosu::Image.new(image);
        @type=type

    end

#level 3 where the obstacles are made to move
    def move_obstacles(block)
        if block.y==500 || block.y==20
            block.vel_y*=-1
        end

        block.y+=block.vel_y

    end


    # checks if the arrow meets with an obstacle. if so, the score decreases by one.
    def collide_obstacles(block, arrow, target, flag)
       # if arrow.y>(block.y) and arrow.y<(target.y+40) and (arrow.x+40)>(block.x) and (arrow.x+40)<(block.x+50)
       if Gosu.distance(arrow.x, arrow.y, block.x, block.y) <30
            target.score-=1
            arrow.count-=1
            target.ohno.play
            sleep(1)
            arrow.x=180
            arrow.y=320
            arrow.end=true
            flag=0
         
            return flag
        end

        if (arrow.x+20)>(block.x+40)
            flag=1
            return flag
        end
  
    end 

    def draw_obstacles(block)
    
        block.image.draw(block.x, block.y, ZOrder::MIDDLE)
    
    end
    

end

#main game window
class CustomProgram< Gosu::Window

    def initialize 
        super(WIDTH, HEIGHT, false)
        self.caption
        @background = Gosu::Image.new('media/background.jpg', :tileable=>true)
        @font = Gosu::Font.new(self, "Futura", HEIGHT / 20)
        @stage= Gosu::Font.new(self, "Peace Sans", 30)
        @intro=Gosu::Image.new("media/intro_screen.jpg")
        @star=Gosu::Image.new("media/star.png")
        @bow=Bow.new()
        @bow.bow_image[2], @bow.bow_image[1], @bow.bow_image[0] = Gosu::Image.load_tiles("media/bow.png", 100, 220)
        @bow.cur_image=@bow.bow_image[0]
        @target=Target.new()
        @arrow=Arrow.new()
        @obstacles=Array.new()
        @flag=1
    

        def button_down id
    
            case id
                #player controls to operate bow
            when Gosu::KB_LEFT # or Gosu::GP_LEFT
                @bow.expand(@bow, @arrow)

            when Gosu::KB_RIGHT 
                @bow.compress(@bow, @arrow)

            when Gosu::KB_UP #or Gosu.button_down? Gosu::GP_BUTTON_0
                if @bow.angle > -50.0
                    @bow.tilt_up(@bow, @arrow)
                end

            when  Gosu::KB_DOWN #or Gosu.button_down? Gosu::GP_BUTTON_9
                if @bow.angle < 50.0
                     @bow.tilt_down(@bow, @arrow)
                end
                #for arrow release
            when Gosu::KbSpace 
                @arrow.end=false

                #to begin the game
            when Gosu::KbReturn # or (Gosu::KbEnter)
                @arrow.count=10

                #to exit the game
            when Gosu::KbEscape
                exit

                #to restart the game in the end
            when Gosu::KbRightShift
                 @arrow.count=11
                 puts("restart")
    
            end

    end

    def update
   
        #managing the movement of the arrow and target
            if @arrow.end==false
                @arrow.shoot(@arrow)
            end
   
    @target.move(@target)

    #to check for collision of the arrow with the target and the obstacles

    @flag=@target.collide(@target, @arrow, @flag)
    
    @obstacles.each do  
        |block| 
        if(@flag!=0)    
            @flag=block.collide_obstacles(block, @arrow, @target, @flag) 
        end
    end
      


    end

    def draw

        #initial screen of instructions displayed
        if(@arrow.count==11)
            draw_instructions(@arrow)
        end


        #to set the level number for display
         if @arrow.count<11 and @arrow.count>7
            level=1
         elsif @arrow.count>4
            level=2
        else
            level=3
        end

        
        #once the game has begun
        if(@arrow.count<11) and (@arrow.count>0)
            #display information on the game screen of score, arrow number and level number
            draw_text(WIDTH/2-50, 40, "Level #{level} ", @stage, Gosu::Color::BLACK)
            draw_text(80, 40, "SCORE: #{@target.score} ", @font, 0xff9400d3)
            draw_text(650, 40, "Arrows Left: #{@arrow.count} ", @font, 0xff9400d3)

            #positioning and drawing the game elements
            @background.draw(0,0, ZOrder::BACKGROUND)
    
            @bow.cur_image.draw_rot(100, 300, ZOrder::MIDDLE, @bow.angle)
            case @bow.cur_image
                when @bow.bow_image[0]
                    x=48
                when @bow.bow_image[1]
                    x=60
                when @bow.bow_image[2]
                    x=80
            end
            @arrow.angle=@bow.angle
    
            @arrow.arrow_image.draw_rot(@arrow.x-x, @arrow.y, ZOrder::TOP, @arrow.angle )

            @target.target_image.draw(@target.x, @target.y, ZOrder::MIDDLE)

    

            #to refresh the obstacles array after each arrow used which is then randomly generated
                
            if  @arrow.count<8 && @arrow.end==true && @flag==0 
                @obstacles.clear
                @flag=1
            end

            index=7

           #for level 2 and level 3
            while index>0 && @arrow.count<8
     
            if @arrow.count==index
 
                 generate_blocks(@obstacles)
       
            end
     
    
             @obstacles.each { |block| block.draw_obstacles(block) }
        
    
            index-=1

     
            if @arrow.count==index
       
                 generate_blocks(@obstacles)
            
            end
       
     
             @obstacles.each { |block| block.draw_obstacles(block) }
           
         #level 3. obstacles that move
                if @arrow.count<5 && @arrow.count>-1 
             

                    @obstacles.each { |block| block.move_obstacles(block) }
                end
            index-=1
     
            end
    
    
        end
        
        #after all 10 arrows are used up the end results screen is displayed
        if(@arrow.count==0)
            draw_results(@target, @font)
        end


end





        def draw_text(x, y, text, font, color)
            font.draw(text, x, y, 3, 1, 1, color)
        end



        def draw_instructions(arrow)

                @intro.draw(0,0, ZOrder::BACKGROUND)

        end


        def draw_results(target, font)
             @background.draw(0,0, ZOrder::BACKGROUND)
            draw_text((WIDTH/2)-200, HEIGHT/2-200, "SCORE: #{target.score} ", @font, 0xffffd700)
            if target.score>-1 and target.score<4
                index=0
            elsif target.score>3 and target.score<8
                index=1
            else
                index=2
            end

            draw_text(600, HEIGHT/2-100, "#{target.result[index]} ", font, 0xffffd700)
            draw_text(100, 400, "Click the Escape key to exit or the Shift key to restart the game ", font, 0xff9400D3)
 
        end

#to randomly pick and add to the obstacles array 
        def generate_blocks(blocks_array)
         size=rand(1..3)
        index=0
        while blocks_array.length<size
            case rand(4)
            when 0
            blocks_array[index]=Obstacle.new("media/man.png", :man)
            when 1
            blocks_array[index]=Obstacle.new("media/tree.png", :tree)
            when 2
            blocks_array[index]=Obstacle.new("media/bird.png", :bird)
            when 3
            blocks_array[index]=Obstacle.new("media/bird2.png", :bird2)
            end

        index+=1
        end
        end




end



CustomProgram.new.show if __FILE__ == $0

    
end
