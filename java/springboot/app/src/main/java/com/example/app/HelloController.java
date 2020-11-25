import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMpping;

@Controller
public class HelloController{

    @GetMpping("/hello")
    public String getHello(){

        return "hello"
    }
}