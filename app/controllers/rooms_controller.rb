class RoomsController < ApplicationController
	#Dokumentacja OpenTok https://github.com/opentok/Opentok-Ruby-SDK/blob/master/doc/reference.md
	# Metoda config_opentok - wywoływana jest jako pierwsza
	before_filter :config_opentok,:except => [:index]
  before_filter :authenticate_user!
  before_filter :current_user_loged
  before_filter :current_room, :only => [:destroy,:party]
  before_filter :user_outside_room, :only =>[:index]

  def index
  # Uzytkownicy w pokojach
  @all_users= User.where.not(:room_id => nil).order("room_id DESC")
  # Publiczne pokoje
	@rooms = Room.where(:public => true).order("created_at DESC")
  # Tworzenie pokoju
  @new_room = Room.new
 
  end

    def create
    params.permit! 
    session = @opentok.create_session request.remote_addr
    params[:room][:sessionId] = session.session_id



    @new_room = Room.new(params[:room])

    respond_to do |format|
      if @new_room.save
        format.html { redirect_to("/party/"+@new_room.id.to_s) }
      else
        format.html { render :controller => 'rooms',
          :action => "index" }
      end
    end
  end

def destroy
@room.destroy
respond_to do |format|
      format.html { redirect_to rooms_url }
      format.json { head :no_content }
    end
    flash[:success] = "Room deleted."


end

  def party
    #Dopisanie uzytkownika do pokoju
   	user_in_room = User.find(@user_id)
    user_in_room.room_id = @room.id
    user_in_room.save


#Inicjacja obiektu OpenTok     
role = OpenTok::RoleConstants::MODERATOR
connection_data = current_user.id
@tok_token = @opentok.generate_token :session_id =>@room.sessionId,:role=>role, :connection_data => connection_data.to_s
   
  end
 
  def config_opentok
  		api_key= '44727722'
  		api_secret = '29e97866780941ea936106816a02ccf53c02a704'
  	if @opentok.nil?
 
     @opentok = OpenTok::OpenTokSDK.new api_key,api_secret
    end
  end

private
  def current_user_loged
    if current_user
     @user_name = current_user.email
     @user_id = current_user.id
   else
     redirect_to new_user_session_path, notice: 'Zostałeś wylogowany.'
   end
  end

  private
      def current_room
        @room = Room.find(params[:id])
        @all_user = @room.users
        @room_name = @room.name
      end

private
      def all_rooms_with_users

      end

private
      def user_outside_room
        user_in_room = User.find(@user_id)
        user_in_room.room_id = nil
        user_in_room.save

      end




end
