// SPDX-License-Identifier: MIT
pragma solidity >=0.7.3 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ChainConnectSocial {

    address public admin;

    mapping(address => bool) public isAdmin;
    uint public  earningsPerInteraction;
    uint256 public postId;
    uint256 public userId;
    IERC20 public tokenAddress;

    mapping(address => User) public users;
    mapping(uint256 => Post) public posts;
    uint256[] public postIds;

    event LikeATweet(address indexed _postAuthor, uint _postId, address  indexed _likeAuthor,uint _time);
    event CommentOnATweet(address indexed _postAuthor, uint _postId, address indexed _commentAuthor, uint _time);
    event IgniteATweet(address indexed _sender, uint _postId, uint _amount, address indexed _postAuthor, uint _time);

    struct Comment {
        address author;
        string comment;
        string imageOne;
        string imageTwo;
        uint256 createdAt;
        string userName;
    }

    struct User {
        uint256 userId;
        address userAddress;
        string profileImage;
        uint256 earnedAmount;
        bool status;
        string profile_name;
        uint256 followerCount;
        uint256 followingCount;
    }

    struct Post {
        uint postId;
        address author;
        string post;
        string imageOne;
        string imageTwo;
        uint256 likeCount;
        uint256 igniteCount;
        uint256 createdAt;
        uint256 commentCount;
    }

    mapping(uint256 => mapping(address => bool)) public postLikes;
    mapping(uint256 => mapping(address => uint256)) public postIgnites;
    mapping(uint256 => Comment[]) public postComments;

        // New Mappings for followers and following
    mapping(address => address[]) public followers;
    mapping(address => address[]) public following;

    constructor(IERC20 _tokenAddress ) {
        tokenAddress = _tokenAddress;
        admin = msg.sender;
        isAdmin[msg.sender] = true;
    }

    function createAPost(string memory usersPost, string memory imageOne, string memory imageTwo) public payable returns(uint) {
        require(users[msg.sender].status,"Status is inactive");
        uint256 newPostId = postId++;
        Post storage post = posts[newPostId];
        post.postId = newPostId;
        post.author = msg.sender;
        post.post = usersPost;
        post.imageOne = imageOne;
        post.imageTwo = imageTwo;
        post.createdAt = block.timestamp;
        postIds.push(newPostId);
        tokenAddress.transfer(msg.sender,earningsPerInteraction);
        return newPostId;
    }

    

    function likeAPost(uint _postId) payable  public {
        require(!postLikes[_postId][msg.sender], "Already liked this post");
        require(users[msg.sender].status,"Status is inactive");
        postLikes[_postId][msg.sender] = true;
        posts[_postId].likeCount++;
        tokenAddress.transfer(msg.sender,earningsPerInteraction);
        emit LikeATweet(posts[_postId].author, _postId,msg.sender, block.timestamp);

    }

    function commentOnPost(uint _postId, string memory comment, string memory imageOne, string memory imageTwo) public payable {
        require(users[msg.sender].status,"Status is inactive");
        postComments[_postId].push(Comment({
            author: msg.sender,
            comment: comment,
            imageOne: imageOne,
            imageTwo: imageTwo,
            userName: users[msg.sender].profile_name,
            createdAt: block.timestamp
        }));
        posts[_postId].commentCount++;
        tokenAddress.transfer(msg.sender,earningsPerInteraction);
        emit CommentOnATweet(posts[_postId].author, _postId, msg.sender,block.timestamp);
    }

    function igniteAPost(uint _postId, uint256, address payable  _author)  public payable  {
        require(users[msg.sender].status,"Status is inactive");
        require(msg.value > 0, "Value  must exceed 0");
        (bool sent,) =_author.call{value:msg.value}("");
        require(sent, "Ignite Failed");
        posts[_postId].igniteCount += 1;
        users[_author].earnedAmount += msg.value;
        emit IgniteATweet(msg.sender, _postId, msg.value, _author,block.timestamp);
      
    }

    function makeAdmin(address newAdmin)   public {
        require(msg.sender == admin, "Only admin can add new admins");
        isAdmin[newAdmin] = true;
    }

    function removeFromAdmin(address adminToRemove)  public {
        require(msg.sender == admin, "Only admin can remove admins");
        isAdmin[adminToRemove] = false;
    }
 
    function deactivateUser(address user)   public {
        require(users[msg.sender].status,"Status is  inactive");
        require(isAdmin[msg.sender], "Only admins can deactivate users");
        users[user].status = false;
    }


    function updateEarningPerInteraction(uint newEarning)   public returns (bool) {
        require(isAdmin[msg.sender],"You are not an admin");
        earningsPerInteraction = newEarning;
        return true;

    }

    function addUser ()   public {
    require(users[msg.sender].userAddress == address(0),"User not found");
    users[msg.sender] = User(userId,msg.sender,"",0,true,"",0,0);
    userId++;
      
    }

    function getUser (address _address) public view returns(User memory user){
        user = users[_address];
        return user;
    }
    
    function getRecentPosts(uint pageNumber, uint pageSize) public view returns (Post[] memory) {
    require(pageSize > 0, "Page size must be greater than 0");
    
    uint totalPosts = postIds.length;
    uint startIndex = totalPosts > pageSize * pageNumber ? totalPosts - pageSize * pageNumber : 0;
    uint endIndex = totalPosts > startIndex + pageSize ? startIndex + pageSize : totalPosts;

    uint numberOfPosts = endIndex - startIndex;
    Post[] memory recentPosts = new Post[](numberOfPosts);

    for (uint i = 0; i < numberOfPosts; i++) {
        recentPosts[i] = posts[postIds[startIndex + i]];
    }

    return recentPosts;
}

   function updateAvatar (string memory avatarCID)   public returns(bool) {
    users[msg.sender].profileImage = avatarCID;
    return true;
    
   }


   function depositToSocialFi(uint256 _amount)   public {
    require(msg.sender == admin, "Not an admin");
    require(tokenAddress.transferFrom(msg.sender, address(this), _amount));


   }

   function socialFiBalance () public view returns(uint256){
    uint256 balance = tokenAddress.balanceOf(address(this));
    return balance;
   }


    function followUser(address _userToFollow) public {
    require(users[msg.sender].status, "Your account is inactive");
    require(users[_userToFollow].status, "User to follow is inactive");
    require(msg.sender != _userToFollow, "You cannot follow yourself");

    // Check if already following
    for (uint i = 0; i < following[msg.sender].length; i++) {
    require(following[msg.sender][i] != _userToFollow, "Already following this user");
    }

    users[msg.sender].followingCount++;
    users[_userToFollow].followerCount++;
    
    // Update followers and following lists
    following[msg.sender].push(_userToFollow);
    followers[_userToFollow].push(msg.sender);
}

function unfollowUser(address _userToUnfollow) public {
    require(users[msg.sender].status, "Your account is inactive");
    require(users[_userToUnfollow].status, "User to unfollow is inactive");
    require(msg.sender != _userToUnfollow, "You cannot unfollow yourself");
    require(users[msg.sender].followingCount > 0, "You are not following anyone");
    require(users[_userToUnfollow].followerCount > 0, "User has no followers");

    users[msg.sender].followingCount--;
    users[_userToUnfollow].followerCount--;

    // Remove user from following and followers lists
    removeUserFromArray(following[msg.sender], _userToUnfollow);
    removeUserFromArray(followers[_userToUnfollow], msg.sender);
}


    function removeUserFromArray(address[] storage array, address userToRemove) internal {
        for (uint i = 0; i < array.length; i++) {
            if (array[i] == userToRemove) {
                array[i] = array[array.length - 1]; // Move the last element to the current index
                array.pop(); // Remove the last element
                break;
            }
        }
    }


function getFollowers(address _user) public view returns (address[] memory) {
    return followers[_user];
}


function getFollowing(address _user) public view returns (address[] memory) {
    return following[_user];
}


}