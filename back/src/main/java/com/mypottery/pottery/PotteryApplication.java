package com.mypottery.pottery;

import com.mypottery.pottery.model.Product;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.context.ApplicationContext;

//@SpringBootApplication(scanBasePackages = "com.mypottery.pottery")
//@EntityScan("com.mypottery.pottery.model")
@SpringBootApplication
public class PotteryApplication {
//	@Autowired
//	private JdbcTemplate jdbcTemplate;

	public static void main(String[] args) throws Exception {

		ApplicationContext ctx = SpringApplication.run(PotteryApplication.class);
	}

//	@Override
//	public void run(String... args) throws Exception{
//		String sql = "SELECT * FROM Product";
//		List<Product> products = jdbcTemplate.query(sql, BeanPropertyRowMapper.newInstance(Product.class));
//		products.forEach(System.out::println);
//	}
}